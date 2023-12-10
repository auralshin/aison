import { useState } from "react";
import { default as ABI } from "../factor/ABI.json";
import type { NextPage } from "next";
import { useContractWrite, usePrepareContractWrite } from "wagmi";

const Invoice: NextPage = () => {
  const [formData, setFormData] = useState({
    invoiceNo: 1,
    invoiceDate: "",
    invoiceAmount: "",
    invoiceCurrency: "",
  });
  const { config } = usePrepareContractWrite({
    address: "0x16925a3dbbd777880708ca868fe36481d0457ce4",
    abi: ABI.abi,
    functionName: "createInvoice",
    args: [
      {
        _tokenId: formData.invoiceNo, // Example tokenId
        _user: "0x6C2A780F93Ec560775133f3Ed2ae669744Fe0f49", // Deployer's address
        details: {
          _merkleRoot: "0x0000000000000000000000000000000000000000000000000000000000000000",
          _invoiceAmount: String(formData.invoiceAmount),
          _invoiceDate: String(formData.invoiceDate),
          _invoiceStatus: "Initiated",
          _invoiceCurrency: String(formData.invoiceCurrency),
        },
      },
    ],
  });
  const { write } = useContractWrite(config);

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
            <div className="flex flex-col bg-base-100 px-10 py-10 text-center items-center w-full max-w-xl rounded-3xl">
              <h1 className="text-2xl mb-2">Create Invoice</h1>
              <form className="flex flex-col gap-4 w-[30vw] form-control">
                <div className="flex flex-col gap-1">
                  <label className="text-sm text-left ml-2">Invoice No.</label>
                  <input
                    type="text"
                    className="input input-bordered"
                    placeholder="Enter Invoice No."
                    value={formData.invoiceNo}
                    onChange={e => {
                      setFormData({ ...formData, invoiceNo: Number(e.target.value) });
                    }}
                  />
                </div>
                <div className="flex flex-col gap-1">
                  <label className="text-sm text-left ml-2">Invoice Date</label>
                  <input
                    type="date"
                    className="input input-bordered"
                    placeholder="Enter Invoice Date"
                    value={formData.invoiceNo}
                    onChange={e => {
                      setFormData({ ...formData, invoiceDate: e.target.value });
                    }}
                  />
                </div>
                <div className="flex flex-col gap-1">
                  <label className="text-sm text-left ml-2">Invoice Amount</label>
                  <input
                    type="text"
                    className="input input-bordered"
                    placeholder="Enter Invoice Amount"
                    value={formData.invoiceAmount}
                    onChange={e => {
                      setFormData({ ...formData, invoiceAmount: e.target.value });
                    }}
                  />
                </div>
                <div className="flex flex-col gap-1">
                  <label className="text-sm text-left ml-2">Invoice Currency</label>
                  <input
                    type="text"
                    className="input input-bordered"
                    placeholder="Enter Invoice Due Date"
                    value={formData.invoiceCurrency}
                    onChange={e => {
                      setFormData({ ...formData, invoiceCurrency: e.target.value });
                    }}
                  />
                </div>
                {/* File Upload */}
                <div className="flex flex-col gap-1">
                  <label className="text-sm text-left ml-2">Invoice File</label>
                  <input type="file" className="file-input file-input-bordered file-input-primary w-full max-w-xl" />
                </div>
                <div className="flex flex-col gap-1">
                  <label className="text-sm text-left ml-2">Invoice Paid</label>
                  <div className="dropdown ">
                    <div tabIndex={0} role="button" className="btn m-1">
                      Choose One Option
                    </div>
                    <ul tabIndex={0} className="dropdown-content z-[1] menu p-2 shadow bg-base-100 rounded-box w-52">
                      <li>
                        <a>Fully Settled</a>
                      </li>
                      <li>
                        <a>Partially Settled</a>
                      </li>
                      <li>
                        <a>Initiated</a>
                      </li>
                    </ul>
                  </div>
                </div>
                {/* Button for Creating trade */}
                <div className="flex justify-center">
                  <button className="btn btn-primary" disabled={!write} onClick={() => write?.()}>
                    Create Invoice
                  </button>
                </div>
              </form>
            </div>
          </div>
        </div>
      </div>
    </>
  );
};

export default Invoice;
