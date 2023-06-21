import { useState } from "react";
import { Button, Input, FormGroup, Label, Container } from "reactstrap";
import { useCelo } from "@celo/react-celo";
import abi from "../utils/abi.json";
import { txn } from "../utils/utils";
export default function Register({ check }) {
  const [uname, setuname] = useState("");
  const { address, getConnectedKit } = useCelo();
  const [freeze, setFreeze] = useState(false);
  const register = () => {
    if (uname.length) {
      setFreeze(true);
      registe(uname)
        .then(() => {
          setFreeze(false);
          window.location.reload();
        })
        .catch((err) => {
          setFreeze(false);
        });
    }
  };
  const registe = async () => {
    if (address.length) {
      const kit = await getConnectedKit();
      const contract = new kit.connection.web3.eth.Contract(abi.abi, txn);
      await contract.methods.setUsername(uname).send({ from: address });
    }
  };
  return (
    <>
      return (
      <div
        style={{
          display: "flex",
          justifyContent: "center",
          alignItems: "center",
          height: "100vh",
          backgroundColor: "#d4edda",
          boxShadow: "0px 0px 10px rgba(0, 0, 0, 0.2)",
        }}
      >
        <div
          style={{
            display: "flex",
            flexDirection: "column",
            justifyContent: "center",
            alignItems: "center",
            padding: "20px",
            backgroundColor: "#fff",
            borderRadius: "10px",
            border: "1px solid #28a745",
            boxShadow: "0px 0px 10px rgba(0, 0, 0, 0.2)",
          }}
        >
          <h2 style={{ marginBottom: "20px" }}>
            {check ? (
              <>Checking the Username</>
            ) : freeze === true ? (
              <>Registering !!!</>
            ) : (
              <>Register Your Username</>
            )}
          </h2>
          <FormGroup floating>
            <Input
              id="Username"
              name="username"
              placeholder="Username"
              type="text"
              value={uname}
              onChange={(e) => setuname(e.currentTarget.value)}
              disabled={freeze || check}
            />
            <Label for="username">Username</Label>
          </FormGroup>

          <Container>
            <Button
              style={{ marginLeft: "25%" }}
              color="success"
              onClick={register}
              disabled={freeze || check}
            >
              Register
            </Button>
          </Container>
        </div>
      </div>
    </>
  );
}
