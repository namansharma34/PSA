import { useCelo } from "@celo/react-celo";
import { Button } from "reactstrap";
export default function Login() {
  const { connect, address } = useCelo();
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
          <h2 style={{ marginBottom: "20px" }}>Login with Celo</h2>
          <Button variant="success" onClick={connect}>
            Connect
          </Button>
        </div>
      </div>
    </>
  );
}
