import React from "react";
import { Navbar, NavbarBrand, Button } from "reactstrap";
import { useCelo } from "@celo/react-celo";
export default function NavBar() {
  const { address, disconnect } = useCelo();
  return (
    <Navbar fixed="top" color="dark">
      <div
        style={{
          display: "flex",
          justifyContent: "center",
          alignItems: "center",
          flex: 1,
        }}
      >
        <NavbarBrand href="/">PSA</NavbarBrand>
      </div>
      {address ? (
        <Button variant="secondary" onClick={disconnect}>
          Disconnect
        </Button>
      ) : null}
    </Navbar>
  );
}
