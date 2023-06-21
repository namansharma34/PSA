import React, { useEffect, useState } from "react";
import {
  Card,
  Button,
  CardBody,
  CardText,
  CardTitle,
  Modal,
  ModalHeader,
  ModalBody,
  ModalFooter,
  InputGroup,
  Input,
} from "reactstrap";
import { Web3Storage } from "web3.storage/dist/bundle.esm.min";
import { useCelo } from "@celo/react-celo";
import abi from "../utils/abi.json";
import { txn } from "../utils/utils";
function CardSS({
  id,
  image,
  description,
  author,
  time,
  likes,
  comments,
  freeze,
  setFreeze,
}) {
  const { address, getConnectedKit } = useCelo();

  useEffect(() => {
    getFile()
      .then()
      .catch((er) => console.log(er));
  }, []);
  const [file, setFile] = useState("");
  const [cmt, setCmt] = useState("");
  const getFile = async () => {
    const client = new Web3Storage({
      token: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJkaWQ6ZXRocjoweEU2NThiNWUxNkE3N2E3ZjJmQzFkMjkxMjQ4NDhmOTRiMWM0OWFBN0MiLCJpc3MiOiJ3ZWIzLXN0b3JhZ2UiLCJpYXQiOjE2ODM3NDUwNDE4ODYsIm5hbWUiOiJnaGppdSJ9.48GI0IIljYjyEtDv5e-pkFsSbBKoHrzKoN3P6QQ9lUg",
    });
    const data = await client.get(image);
    const file = await data.files();
    const reader = new FileReader();
    reader.addEventListener("load", () => {
      setFile(reader.result);
    });
    reader.readAsDataURL(file[0]);
  };
  const [modal, setModal] = useState(false);
  const toggle = () => setModal(!modal);
  const like = async () => {
    setFreeze(true);
    const kit = await getConnectedKit();
    const contract = new kit.connection.web3.eth.Contract(abi.abi, txn);
    await contract.methods.likePhoto(id).send({ from: address });
  };
  const likethephoto = () => {
    like()
      .then(() => {
        setFreeze(false);
        window.location.reload();
      })
      .catch((err) => {
        setFreeze(false);
        console.log(err);
      });
  };
  const mkcmt = (idss) => {
    if (cmt.length && Number(idss) > 0) {
      Amkcmt(idss)
        .then(() => {
          setFreeze(false);
          window.location.reload();
        })
        .catch((err) => {
          setFreeze(false);
          console.log(err);
        });
    }
  };
  const Amkcmt = async (idss) => {
    setFreeze(true);
    const kit = await getConnectedKit();
    const contract = new kit.connection.web3.eth.Contract(abi.abi, txn);
    await contract.methods
      .addComment(idss, String(cmt))
      .send({ from: address });
  };
  return (
    <div>
      <Card className="my-3" key={id}>
        <CardBody>
          <CardTitle tag={"h5"} color="black">
            {description}
          </CardTitle>
          <img src={file} height={"250vh"} width={"400vh"} />
          <hr />
          <CardText>
            {author} <b>{"->"}</b> {Date(time)}
          </CardText>
          <hr />
          {likes.length ? (
            likes.filter(
              (e) => String(e).toUpperCase() === String(address).toUpperCase()
            ).length ? (
              <Button variant="primary" className="mr-2" disabled={true}>
                {likes.length} Liked
              </Button>
            ) : (
              <Button
                variant="primary"
                className="mr-2"
                disabled={freeze}
                onClick={likethephoto}
              >
                {likes.length} Like
              </Button>
            )
          ) : (
            <Button
              variant="primary"
              className="mr-2"
              disabled={freeze}
              onClick={likethephoto}
            >
              {likes.length} Like
            </Button>
          )}{" "}
          <Button variant="primary" disabled={freeze} onClick={toggle}>
            {comments.length} Comment
          </Button>
        </CardBody>
      </Card>
      <Modal isOpen={modal} toggle={toggle}>
        <ModalHeader toggle={toggle}>{comments.length} Comment</ModalHeader>
        <ModalBody>
          <InputGroup>
            <Input
              name="comment"
              placeholder="Comment ...!"
              type="text"
              value={cmt}
              onChange={(e) => setCmt(e.currentTarget.value)}
              disabled={freeze}
            />
            <Button color="success" onClick={() => mkcmt(id)} disabled={freeze}>
              Comment
            </Button>
          </InputGroup>
          <br />
          <hr />
          {comments.length
            ? comments.map((e, i) => (
                <>
                  <CardText key={i}>
                    <b key={i + 1}>{e.username}</b> <i key={i + 2}>{"->"}</i>{" "}
                    {e.text}
                  </CardText>
                  <hr key={i + 3} />
                </>
              ))
            : null}
        </ModalBody>
        <ModalFooter>
          <Button color="secondary" onClick={toggle} disabled={freeze}>
            Close
          </Button>
        </ModalFooter>
      </Modal>
    </div>
  );
}

export default CardSS;
