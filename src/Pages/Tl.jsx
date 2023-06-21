import React, { useEffect, useState } from "react";
import { useCelo } from "@celo/react-celo";
import abi from "../utils/abi.json";
import { txn } from "../utils/utils";
import { Container, Row, Col } from "reactstrap";
import CardSS from "../Component/Card";
export default function Tl() {
  const { getConnectedKit } = useCelo();
  const [data, setData] = useState([]);
  const [freeze, setFreeze] = useState(false);
  const getData = async () => {
    const kit = await getConnectedKit();
    const contract = new kit.connection.web3.eth.Contract(abi.abi, txn);
    const _data = await contract.methods.getAllPhotos().call();
    setData(_data);
  };
  useEffect(() => {
    getData().then();
  }, []);
  return (
    <div>
      {data.length ? (
        <>
          <Container>
            <Row className="justify-content-center">
              <Col md={5}>
                {data.map((e) => {
                  console.log(data);
                  return (
                    <CardSS
                      key={e.id}
                      id={Number(e.id)}
                      image={String(e.ipfsHash)}
                      description={String(e.description)}
                      author={String(e.author)}
                      time={e.time}
                      likes={e.likes}
                      comments={e.comments}
                      freeze={freeze}
                      setFreeze={setFreeze}
                    />
                  );
                })}
              </Col>
            </Row>
          </Container>
        </>
      ) : (
        <div>
          <h1>There is No Data or You have not register your username</h1>
        </div>
      )}
    </div>
  );
}
