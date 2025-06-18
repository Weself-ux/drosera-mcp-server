use anyhow::Result;
use serde_json::{json, Value};
use std::collections::HashMap;
use std::fs;
use std::io::{self, BufRead, Write};
use std::path::Path;
use tracing::info;

// Simple MCP server implementation that works with stdio
// This implements the basic MCP protocol directly

struct DroseraServer {
    protocols: HashMap<String, Value>,
    drosera_context: HashMap<String, Value>,
    trap_examples: HashMap<String, Value>,
}

impl DroseraServer {
    fn new() -> Result<Self> {
        let mut server = Self {
            protocols: HashMap::new(),
            drosera_context: HashMap::new(),
            trap_examples: HashMap::new(),
        };
        server.load_protocols()?;
        server.load_drosera_context()?;
        server.load_trap_examples()?;
        Ok(server)
    }

    fn load_protocols(&mut self) -> Result<()> {
        let protocols_dir = Path::new("src/data/protocols");
        
        if !protocols_dir.exists() {
            info!("Protocols directory not found");
            return Ok(());
        }

        // Look for protocol directories (new structure)
        for entry in fs::read_dir(protocols_dir)? {
            let entry = entry?;
            let path = entry.path();
            
            if path.is_dir() {
                if let Some(protocol_name) = path.file_name().and_then(|s| s.to_str()) {
                    info!("Loading protocol: {}", protocol_name);
                    if let Ok(protocol_data) = self.load_structured_protocol(&path) {
                        self.protocols.insert(protocol_name.to_string(), protocol_data);
                    }
                }
            }
        }
        
        Ok(())
    }

    fn load_structured_protocol(&self, protocol_dir: &Path) -> Result<Value> {
        let mut protocol_data = json!({
            "networks": {},
            "abis": {}
        });
        
        // Load ABIs
        let abis_dir = protocol_dir.join("abis");
        if abis_dir.exists() {
            let mut abis = json!({});
            for entry in fs::read_dir(&abis_dir)? {
                let entry = entry?;
                let path = entry.path();
                if path.extension().and_then(|s| s.to_str()) == Some("json") {
                    if let Some(interface) = path.file_stem().and_then(|s| s.to_str()) {
                        let content = fs::read_to_string(&path)?;
                        let abi_data: Value = serde_json::from_str(&content)?;
                        abis[interface] = abi_data;
                    }
                }
            }
            protocol_data["abis"] = abis;
        }
        
        // Load misc_data (which now contains all protocol info per network)
        let misc_data_dir = protocol_dir.join("misc_data");
        if misc_data_dir.exists() {
            let mut networks = json!({});
            for entry in fs::read_dir(&misc_data_dir)? {
                let entry = entry?;
                let path = entry.path();
                if path.extension().and_then(|s| s.to_str()) == Some("json") {
                    if let Some(network) = path.file_stem().and_then(|s| s.to_str()) {
                        let content = fs::read_to_string(&path)?;
                        let network_data: Value = serde_json::from_str(&content)?;
                        networks[network] = network_data;
                    }
                }
            }
            protocol_data["networks"] = networks;
        }
        
        Ok(protocol_data)
    }

    fn load_drosera_context(&mut self) -> Result<()> {
        let context_dir = Path::new("src/data/drosera-context");
        
        if !context_dir.exists() {
            info!("Drosera context directory not found");
            return Ok(());
        }

        // Load documentation files
        if let Ok(website_dir) = context_dir.join("website/docs/pages").read_dir() {
            for entry in website_dir {
                let entry = entry?;
                let path = entry.path();
                
                if path.is_file() && path.extension().and_then(|s| s.to_str()) == Some("md") {
                    if let Some(name) = path.file_stem().and_then(|s| s.to_str()) {
                        let content = fs::read_to_string(&path)?;
                        self.drosera_context.insert(name.to_string(), json!({
                            "type": "documentation",
                            "content": content,
                            "path": path.to_string_lossy()
                        }));
                    }
                }
            }
        }
        
        // Load subdirectories (operators, trappers)
        for subdir in ["operators", "trappers"] {
            let subdir_path = context_dir.join("website/docs/pages").join(subdir);
            if subdir_path.exists() {
                if let Ok(entries) = subdir_path.read_dir() {
                    for entry in entries {
                        let entry = entry?;
                        let path = entry.path();
                        
                        if path.is_file() && path.extension().and_then(|s| s.to_str()) == Some("md") {
                            if let Some(name) = path.file_stem().and_then(|s| s.to_str()) {
                                let content = fs::read_to_string(&path)?;
                                let key = format!("{}/{}", subdir, name);
                                self.drosera_context.insert(key, json!({
                                    "type": "documentation",
                                    "category": subdir,
                                    "content": content,
                                    "path": path.to_string_lossy()
                                }));
                            }
                        }
                    }
                }
            }
        }
        
        Ok(())
    }

    fn load_trap_examples(&mut self) -> Result<()> {
        let examples_dir = Path::new("src/data/trap-examples");
        
        if !examples_dir.exists() {
            info!("Trap examples directory not found");
            return Ok(());
        }

        // Load each example directory
        for entry in fs::read_dir(examples_dir)? {
            let entry = entry?;
            let path = entry.path();
            
            if path.is_dir() {
                if let Some(example_name) = path.file_name().and_then(|s| s.to_str()) {
                    info!("Loading trap example: {}", example_name);
                    
                    let mut example_data = json!({
                        "name": example_name,
                        "type": "trap_example"
                    });
                    
                    // Load README if exists
                    let readme_path = path.join("README.md");
                    if readme_path.exists() {
                        let content = fs::read_to_string(&readme_path)?;
                        example_data["readme"] = json!(content);
                    }
                    
                    // Load source files
                    let src_dir = path.join("src");
                    if src_dir.exists() {
                        let mut sources = json!({});
                        if let Ok(entries) = src_dir.read_dir() {
                            for src_entry in entries {
                                let src_entry = src_entry?;
                                let src_path = src_entry.path();
                                
                                if src_path.is_file() && src_path.extension().and_then(|s| s.to_str()) == Some("sol") {
                                    if let Some(file_name) = src_path.file_name().and_then(|s| s.to_str()) {
                                        let content = fs::read_to_string(&src_path)?;
                                        sources[file_name] = json!(content);
                                    }
                                }
                            }
                        }
                        example_data["sources"] = sources;
                    }
                    
                    // Load test files
                    let test_dir = path.join("test");
                    if test_dir.exists() {
                        let mut tests = json!({});
                        if let Ok(entries) = test_dir.read_dir() {
                            for test_entry in entries {
                                let test_entry = test_entry?;
                                let test_path = test_entry.path();
                                
                                if test_path.is_file() && test_path.extension().and_then(|s| s.to_str()) == Some("sol") {
                                    if let Some(file_name) = test_path.file_name().and_then(|s| s.to_str()) {
                                        let content = fs::read_to_string(&test_path)?;
                                        tests[file_name] = json!(content);
                                    }
                                }
                            }
                        }
                        example_data["tests"] = tests;
                    }
                    
                    self.trap_examples.insert(example_name.to_string(), example_data);
                }
            }
        }
        
        Ok(())
    }

}

impl DroseraServer {
    async fn handle_request(&self, request: Value) -> Result<Value> {
        let method = request["method"].as_str().unwrap_or("");
        let id = request.get("id").cloned().unwrap_or(Value::Null);
        
        // Handle notifications (requests without id)
        if id.is_null() {
            if method == "notifications/initialized" {
                return Ok(Value::Null); // No response for notifications
            } else {
                // For requests that should have an ID but don't, return an error with null ID
                return Ok(json!({
                    "jsonrpc": "2.0",
                    "id": Value::Null,
                    "error": {
                        "code": -32600,
                        "message": "Invalid Request: missing id field"
                    }
                }));
            }
        }

        match method {
            "notifications/initialized" => {
                // This is a notification, no response expected
                Ok(Value::Null)
            }
            "initialize" => {
                Ok(json!({
                    "jsonrpc": "2.0",
                    "id": id,
                    "result": {
                        "protocolVersion": "2024-11-05",
                        "capabilities": {
                            "tools": {},
                            "resources": {}
                        },
                        "serverInfo": {
                            "name": "drosera-traps-mcp",
                            "version": "1.0.0"
                        }
                    }
                }))
            }
            "tools/list" => {
                Ok(json!({
                    "jsonrpc": "2.0",
                    "id": id,
                    "result": {
                        "tools": []
                    }
                }))
            }
            "tools/call" => {
                Ok(json!({
                    "jsonrpc": "2.0",
                    "id": id,
                    "error": {
                        "code": -32601,
                        "message": "No tools available - use resources instead"
                    }
                }))
            }
            "resources/list" => {
                let mut resources = Vec::new();
                
                // Add protocol resources
                for (protocol_name, protocol_data) in &self.protocols {
                    // Add network resources from misc_data
                    if let Some(networks) = protocol_data.get("networks").and_then(|n| n.as_object()) {
                        for network in networks.keys() {
                            resources.push(json!({
                                "uri": format!("protocol://{}/misc_data/{}", protocol_name, network),
                                "name": format!("{} {} Protocol Data", 
                                    protocol_name.chars().next().unwrap().to_uppercase().collect::<String>() + &protocol_name[1..],
                                    network.chars().next().unwrap().to_uppercase().collect::<String>() + &network[1..]
                                ),
                                "description": format!("Complete protocol data including contracts, tokens, pools, ABIs, and functions for {} on {}", protocol_name, network),
                                "mimeType": "application/json"
                            }));
                        }
                    }
                    
                    // Add ABI resources
                    if let Some(abis) = protocol_data.get("abis").and_then(|a| a.as_object()) {
                        for interface_name in abis.keys() {
                            resources.push(json!({
                                "uri": format!("protocol://{}/abi/{}", protocol_name, interface_name),
                                "name": format!("{} {} Interface", protocol_name, interface_name),
                                "description": format!("ABI and function signatures for {} interface", interface_name),
                                "mimeType": "application/json"
                            }));
                        }
                    }
                    
                }
                
                // Add Drosera context resources
                for (doc_name, _doc_data) in &self.drosera_context {
                    resources.push(json!({
                        "uri": format!("drosera://{}", doc_name),
                        "name": format!("Drosera {}", doc_name.replace('-', " ").replace('/', " - ")),
                        "description": format!("Drosera documentation: {}", doc_name),
                        "mimeType": "text/markdown"
                    }));
                }
                
                // Add trap example resources
                for (example_name, _example_data) in &self.trap_examples {
                    resources.push(json!({
                        "uri": format!("trap-example://{}", example_name),
                        "name": format!("{} Trap Example", example_name.replace('-', " ").chars().collect::<String>()),
                        "description": format!("Complete trap example: {}", example_name),
                        "mimeType": "application/json"
                    }));
                }

                Ok(json!({
                    "jsonrpc": "2.0",
                    "id": id,
                    "result": {
                        "resources": resources
                    }
                }))
            }
            "resources/read" => {
                let uri = request["params"]["uri"].as_str().unwrap_or("");
                
                if uri.starts_with("protocol://") {
                    let path = uri.strip_prefix("protocol://").unwrap();
                    let parts: Vec<&str> = path.split('/').collect();
                    
                    if parts.len() >= 2 {
                        let protocol_name = parts[0];
                        
                        if let Some(protocol_data) = self.protocols.get(protocol_name) {
                            match parts.len() {
                                3 => {
                                    let resource_type = parts[1];
                                    let resource_name = parts[2];
                                    
                                    match resource_type {
                                        "abi" => {
                                            // protocol://uniswap/abi/IUniswapV3Pool
                                            if let Some(abi_data) = protocol_data.get("abis")
                                                .and_then(|a| a.get(resource_name)) {
                                                
                                                return Ok(json!({
                                                    "jsonrpc": "2.0",
                                                    "id": id,
                                                    "result": {
                                                        "contents": [{
                                                            "type": "text",
                                                            "text": serde_json::to_string_pretty(&abi_data)?
                                                        }]
                                                    }
                                                }));
                                            }
                                        }
                                        "misc_data" => {
                                            // protocol://uniswap/misc_data/mainnet
                                            if let Some(network_data) = protocol_data.get("networks")
                                                .and_then(|n| n.get(resource_name)) {
                                                
                                                // Return the complete network data with ABIs included
                                                let mut result = network_data.clone();
                                                if let Some(abis) = protocol_data.get("abis") {
                                                    result["abis"] = abis.clone();
                                                }
                                                
                                                return Ok(json!({
                                                    "jsonrpc": "2.0",
                                                    "id": id,
                                                    "result": {
                                                        "contents": [{
                                                            "type": "text",
                                                            "text": serde_json::to_string_pretty(&result)?
                                                        }]
                                                    }
                                                }));
                                            }
                                        }
                                        _ => {}
                                    }
                                }
                                _ => {}
                            }
                            
                            return Ok(json!({
                                "jsonrpc": "2.0",
                                "id": id,
                                "error": {
                                    "code": -32602,
                                    "message": format!("Resource not found: {}", uri)
                                }
                            }));
                        } else {
                            return Ok(json!({
                                "jsonrpc": "2.0",
                                "id": id,
                                "error": {
                                    "code": -32602,
                                    "message": format!("Protocol '{}' not found", protocol_name)
                                }
                            }));
                        }
                    } else {
                        return Ok(json!({
                            "jsonrpc": "2.0",
                            "id": id,
                            "error": {
                                "code": -32602,
                                "message": "Invalid protocol URI format"
                            }
                        }));
                    }
                } else if uri.starts_with("drosera://") {
                    let doc_name = uri.strip_prefix("drosera://").unwrap();
                    
                    if let Some(doc_data) = self.drosera_context.get(doc_name) {
                        let content = doc_data.get("content").and_then(|c| c.as_str()).unwrap_or("");
                        
                        return Ok(json!({
                            "jsonrpc": "2.0",
                            "id": id,
                            "result": {
                                "contents": [{
                                    "type": "text",
                                    "text": content
                                }]
                            }
                        }));
                    } else {
                        return Ok(json!({
                            "jsonrpc": "2.0",
                            "id": id,
                            "error": {
                                "code": -32602,
                                "message": format!("Drosera documentation '{}' not found", doc_name)
                            }
                        }));
                    }
                } else if uri.starts_with("trap-example://") {
                    let example_name = uri.strip_prefix("trap-example://").unwrap();
                    
                    if let Some(example_data) = self.trap_examples.get(example_name) {
                        return Ok(json!({
                            "jsonrpc": "2.0",
                            "id": id,
                            "result": {
                                "contents": [{
                                    "type": "text",
                                    "text": serde_json::to_string_pretty(&example_data)?
                                }]
                            }
                        }));
                    } else {
                        return Ok(json!({
                            "jsonrpc": "2.0",
                            "id": id,
                            "error": {
                                "code": -32602,
                                "message": format!("Trap example '{}' not found", example_name)
                            }
                        }));
                    }
                } else {
                    Ok(json!({
                        "jsonrpc": "2.0",
                        "id": id,
                        "error": {
                            "code": -32602,
                            "message": format!("Unknown resource URI: {}", uri)
                        }
                    }))
                }
            }
            "prompts/list" => {
                Ok(json!({
                    "jsonrpc": "2.0",
                    "id": id,
                    "result": {
                        "prompts": []
                    }
                }))
            }
            _ => {
                Ok(json!({
                    "jsonrpc": "2.0",
                    "id": id,
                    "error": {
                        "code": -32601,
                        "message": format!("Unknown method: {}", method)
                    }
                }))
            }
        }
    }
}

#[tokio::main]
async fn main() -> Result<()> {
    // Configure tracing to write to stderr instead of stdout
    tracing_subscriber::fmt()
        .with_writer(std::io::stderr)
        .init();
    
    info!("🦀 Starting Drosera Traps MCP Server (Rust)...");

    let server = DroseraServer::new()?;
    let stdin = io::stdin();
    let mut stdout = io::stdout();
    
    // Simple MCP protocol implementation
    for line in stdin.lock().lines() {
        let line = line?;
        if line.trim().is_empty() {
            continue;
        }

        // Parse JSON-RPC message
        if let Ok(request) = serde_json::from_str::<Value>(&line) {
            let response = server.handle_request(request).await?;
            
            // Only send response if it's not null (notifications don't get responses)
            if !response.is_null() {
                let response_str = serde_json::to_string(&response)?;
                writeln!(stdout, "{}", response_str)?;
                stdout.flush()?;
            }
        }
    }

    Ok(())
}

