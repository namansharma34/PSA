import React, { useState } from "react";
import {
  Button,
  Modal,
  ModalHeader,
  ModalBody,
  ModalFooter,
  FormGroup,
  Label,
  Input,
  Form,
} from "reactstrap";
import { Web3Storage } from "web3.storage/dist/bundle.esm.min";
import { useCelo } from "@celo/react-celo";
import abi from "../utils/abi.json";
import { txn } from "../utils/utils";
function PostU() {
  const [modal, setModal] = useState(false);
  const [img, setImg] = useState();
  const toggle = () => setModal(!modal);
  const { address, getConnectedKit } = useCelo();
  const [freeze, setFreeze] = useState(false);
  const handle = (e) => {
    e.preventDefault();
    const description = e.target.description.value;
    if (description && img) {
      upload(description, img)
        .then(() => window.location.reload())
        .catch((err) => console.log(err));
    }
  };
  const upload = async (description, img) => {
    const client = new Web3Storage({
      token: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJkaWQ6ZXRocjoweEU2NThiNWUxNkE3N2E3ZjJmQzFkMjkxMjQ4NDhmOTRiMWM0OWFBN0MiLCJpc3MiOiJ3ZWIzLXN0b3JhZ2UiLCJpYXQiOjE2ODM3NDUwNDE4ODYsIm5hbWUiOiJnaGppdSJ9.48GI0IIljYjyEtDv5e-pkFsSbBKoHrzKoN3P6QQ9lUg",
    });
    setFreeze(true);
    const rootCid = await client.put(img, {
      name: `${address}+${Date.now()}`,
      maxRetries: 3,
    });
    const kit = await getConnectedKit();
    const contract = new kit.connection.web3.eth.Contract(abi.abi, txn);
    await contract.methods
      .uploadPhoto(rootCid, description)
      .send({ from: address });
    setFreeze(false);
  };
  const im = (e) => {
    const input = e.currentTarget;
    const pf = input.files[0];
    const newFile = new File([pf], `${address}.png`);
    const dt = new DataTransfer();
    dt.items.add(newFile);
    setImg(dt.files);
  };
  return (
    <div style={{ marginTop: "90px" }}>
      <div className="d-flex justify-content-center">
        <Button color="success" size="lg" onClick={toggle}>
          Add in the Feed!
        </Button>
      </div>
      <Modal isOpen={modal} toggle={toggle}>
        <ModalHeader color="info" toggle={toggle}>
          {freeze === true ? <>Uploading ...</> : <>Upload</>}
        </ModalHeader>
        <Form onSubmit={handle}>
          <ModalBody>
            <FormGroup>
              <Label for="file">Image</Label>
              <Input
                id="file"
                name="file"
                type="file"
                onChange={im}
                disabled={freeze}
              />
            </FormGroup>
            <FormGroup>
              <Label for="description">Description</Label>
              <Input
                id="description"
                name="description"
                placeholder="Your Description"
                type="text"
                disabled={freeze}
              />
            </FormGroup>
          </ModalBody>
          <ModalFooter>
            <Button color="primary" type="submit" disabled={freeze}>
              Submit
            </Button>{" "}
            <Button color="secondary" onClick={toggle} disabled={freeze}>
              Cancel
            </Button>
          </ModalFooter>
        </Form>
      </Modal>
    </div>
  );
}

export default PostU;
