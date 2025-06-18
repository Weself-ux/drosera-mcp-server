import { defineConfig } from "vocs";
// import tsconfigPaths from "vite-tsconfig-paths";

export default defineConfig({
  title: "Docs",
  // NOTE: vite config for testing purposes
  // vite: {
  //   build: {
  //     minify: "terser",
  //   },
  //   server: {
  //     allowedHosts: true,
  //     port: 5173,
  //   },
  //   plugins: [tsconfigPaths()],
  // },
  // sponsors: [
  //   {
  //     name: "Collaborator",
  //     height: 120,
  //     items: [
  //       [
  //         {
  //           name: "Paradigm",
  //           link: "https://paradigm.xyz",
  //           image:
  //             "https://raw.githubusercontent.com/wevm/.github/main/content/sponsors/paradigm-light.svg",
  //         },
  //       ],
  //     ],
  //   },
  // ],
  theme: {
    accentColor: "#ff6a00",
    colorScheme: "dark",
  },
  sidebar: [
    {
      text: "Introduction",
      link: "/introduction",
    },
    {
      text: "Use Cases",
      link: "/use-cases",
    },
    {
      text: "Trappers",
      items: [
        { text: "Getting Started", link: "/trappers/getting-started" },
        { text: "Drosera CLI", link: "/trappers/drosera-cli" },
        { text: "Creating a Trap", link: "/trappers/creating-a-trap" },
        { text: "Updating a Trap", link: "/trappers/updating-a-trap" },
        { text: "Hydrating a Trap", link: "/trappers/hydrating-a-trap" },
        { text: "Boosting a Trap", link: "/trappers/boosting-a-trap" },
        { text: "Dryrunning a Trap", link: "/trappers/dryrunning-a-trap" },
        { text: "Kicking an Operator", link: "/trappers/kicking-an-operator" },
        { text: "Private Traps", link: "/trappers/private-traps" },
        {
          text: "Setting Bloomboost Percentage",
          link: "/trappers/setting-bloomboost-percentage",
        },
        {
          text: "Getting Liveness Data",
          link: "/trappers/getting-liveness-data",
        },
        {
          text: "Recovering your drosera.toml File",
          link: "/trappers/recover-drosera-toml",
        },
      ],
    },
    {
      text: "Operators",
      items: [
        { text: "Installation", link: "/operators/installation" },
        { text: "Register", link: "/operators/register" },
        { text: "Run Operator", link: "/operators/run-operator" },
        { text: "Executing Traps", link: "/operators/executing-traps" },
        { text: "Metrics", link: "/operators/metrics" },
        { text: "Testnet Guide", link: "/operators/testnet-guide" },
        { text: "Run on VPS", link: "/operators/run-on-vps" },
        { text: "Run with Docker", link: "/operators/run-with-docker" },
        { text: "Railway", link: "/operators/railway" },
      ],
    },
    {
      text: "Deployments",
      link: "/deployments",
    },
    {
      text: "Litepaper",
      link: "/litepaper",
    },
  ],
  logoUrl: "/img/drosera-symbol.png",
  iconUrl: { light: "/favicon.png", dark: "/favicon.png" },
  socials: [
    { icon: "github", link: "https://github.com/drosera-network" },
    { icon: "discord", link: "https://discord.gg/drosera" },
    {
      icon: "x",
      link: "https://x.com/droseranetwork",
    },
    { icon: "telegram", link: "https://t.me/droseraofficial" },
    // TODO: wait for vocs to add { icon: "youtube", link: "https://www.youtube.com/@youtube.DROSERA" },
  ],
  topNav: [
    {
      text: "Docs",
      link: "/introduction",
    },
    {
      text: "Examples",
      link: "https://github.com/drosera-network/examples",
    },
    {
      text: "1.0.0",
      items: [
        {
          text: "Releases",
          link: "https://github.com/drosera-network/drosera/releases",
        },
      ],
    },
  ],
  head() {
    return (
      <>
        <meta name="twitter:card" content="summary" />
        <meta property="og:title" content="Drosera Docs" />
        <meta
          property="og:description"
          content="Infinite bandwith for the infinite forest"
        />
        <meta
          property="og:image"
          content="https://raw.githubusercontent.com/drosera-network/examples/649b0b21a220cdc45a2bfe86fa6245c423ad16ba/DroseraHeader.jpeg"
        />
      </>
    );
  },
});
