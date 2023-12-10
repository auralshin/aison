import type { NextPage } from "next";

const Invoice: NextPage = () => {
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
              <h1 className="text-2xl mb-2">Initiate Trade</h1>
              <form className="flex flex-col gap-4 w-[30vw] form-control">
                <div className="flex flex-col gap-1">
                  <label className="text-sm text-left ml-2">Invoice No.</label>
                  <input type="text" className="input input-bordered" placeholder="Enter Invoice No." />
                </div>
                <div className="flex flex-col gap-1">
                  <label className="text-sm text-left ml-2">NFT Address</label>
                  <input type="text" className="input input-bordered" placeholder="Enter Invoice Address" />
                </div>
                <div className="flex flex-col gap-1">
                  <label className="text-sm text-left ml-2">Trade Type</label>
                  <input type="text" className="input input-bordered" placeholder="Enter trade Type" />
                </div>
                <div className="flex flex-col gap-1">
                  <label className="text-sm text-left ml-2">Invoice Due Date</label>
                  <input type="date" className="input input-bordered" placeholder="Enter Invoice Due Date" />
                </div>
                {/* File Upload */}
                {/* Button for Creating trade */}
                <div className="flex justify-center">
                  <button className="btn btn-primary">Initiate Trade</button>
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
