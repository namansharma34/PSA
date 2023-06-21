import React from "react";
import ReactDOM from "react-dom/client";
import NavBar from "./Component/NavBar";
import { CeloProvider, Alfajores, NetworkNames } from "@celo/react-celo";
import "@celo/react-celo/lib/styles.css";
import App from "./App";
require('dotenv').config();
const Index = () => (
  <React.Fragment>
    <CeloProvider
      dapp={{
        name: "PSA",
        description: "Decentralized Photo Sharing Application",
        url: "",
      }}
      defaultNetwork={[Alfajores]}
      network={{
        name: NetworkNames.Alfajores,
        rpcUrl: "https://alfajores-forno.celo-testnet.org",
        graphQl: "https://alfajores-blockscout.celo-testnet.org/graphiql",
        explorer: "https://alfajores-blockscout.celo-testnet.org",
        chainId: 44787,
      }}
    >
      <NavBar />
      <App />
    </CeloProvider>
  </React.Fragment>
);
const root = ReactDOM.createRoot(document.getElementById("mountNode"));
root.render(<Index />);
