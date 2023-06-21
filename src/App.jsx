import { useCelo } from "@celo/react-celo";
import Login from "./Pages/Login";
import Register from "./Pages/Register";
import { useEffect, useState } from "react";
import { useCelo } from "@celo/react-celo";
import abi from "./utils/abi.json";
import { txn } from "./utils/utils";
import Feed from "./Pages/Feed";
export default function App() {
  const { address, getConnectedKit } = useCelo();
  const [isuname, setuname] = useState(false);
  const [check, setCheck] = useState(true);
  useEffect(() => {
    if (address) {
      checkUser().then((data) => {
        if (data === true) {
          setuname(true);
          setCheck(false);
        } else {
          setuname(false);
          setCheck(false);
        }
      });
    }
  }, []);
  async function checkUser() {
    const kit = await getConnectedKit();
    const contract = new kit.connection.web3.eth.Contract(abi.abi, txn);
    const data = await contract.methods.checkAddress().call();
    return data;
  }
  return (
    <>
      {address ? (
        <>{isuname ? <Feed /> : <Register check={check} />}</>
      ) : (
        <Login />
      )}
    </>
  );
}
