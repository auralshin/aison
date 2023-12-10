import { useEffect, useState } from "react";
import Image from "next/image";
import { useSearchParams } from "next/navigation";
import { default as ABI } from "../factor/ABI.json";
import { ethers } from "ethers";
import type { NextPage } from "next";

const Update: NextPage = () => {
  const [nftImage, setNftImage] = useState<string>("");
  const [loading, setLoading] = useState<boolean>(true);
  const searchParams = useSearchParams();
  const search = searchParams.get("id");

  useEffect(() => {
    const initiateContract = async () => {
      try {
        // https://base-goerli.g.alchemy.com/v2/7qVldCL8lSY24briWFE5FJ-JOKywWY-H
        const alchemyApiKey = "7qVldCL8lSY24briWFE5FJ-JOKywWY-H";
        const providerr = new ethers.AlchemyProvider("base-goerli", alchemyApiKey);

        // instance of contract

        const trufflesContract = new ethers.Contract("0x16925a3dbbd777880708ca868fe36481d0457ce4", ABI.abi, providerr);
        console.log(search);
        const tx = await trufflesContract.tokenURI(`${search}`);

        const jsonData = tx.replace(/^data:application\/json;base64,/, "");

        const decodedString = atob(jsonData);

        const jsonObject = JSON.parse(decodedString);
        console.log(jsonObject.image);

        setNftImage(jsonObject.image);
        setLoading(false);
      } catch (e) {
        console.log(e);
      }
    };

    initiateContract();
  }, [search]);

  const NFTimage = () => {
    if (loading) {
      return <div className="animate-pulse h-96 w-96 bg-base-200 rounded-lg"></div>;
    } else {
      return (
        <div className="bg-base-200 rounded-lg">
          <Image src={nftImage} alt="NFT Image" width={384} height={384} />
        </div>
      );
    }
  };
  return (
    <>
      <div className="flex items-center flex-col flex-grow pt-10">
        <div className="px-5">
          <h1 className="text-center mb-8">
            <span className="block text-2xl mb-2">Welcome to</span>
            <span className="block text-4xl font-bold">Aison</span>
          </h1>
          <p className="text-center text-lg">Raise Invoice, Settle Trade and automate the process</p>
        </div>

        <div className="flex-grow bg-base-300 w-full mt-16 px-8 py-12">
          <div className="flex justify-center items-center gap-12 flex-col sm:flex-row">
            <div className="flex flex-col bg-base-100 px-10 py-10 text-center items-center w-full max-w-xl rounded-3xl h-[90vh]">
              <NFTimage />
            </div>
            <div className="flex flex-col bg-base-100 px-10 py-10 text-center items-center w-full max-w-xl rounded-3xl h-[90vh]">
              <form className="flex flex-col gap-4 w-[30vw] form-control">
                <div className="flex flex-col gap-1">
                  <label className="text-sm text-left ml-2">Update Status</label>
                  <input type="text" className="input input-bordered" placeholder="Enter Desired Token" />
                </div>
                <div className="flex flex-col gap-1">
                  <label className="text-sm text-left ml-2">Merkle Proof</label>
                  <input type="text" className="input input-bordered" placeholder="Enter Initial Liquidity" />
                </div>
                <div className="flex justify-center">
                  <button className="btn btn-primary">Update Invoice</button>
                </div>
              </form>
            </div>
          </div>
        </div>
      </div>
    </>
  );
};

export default Update;
