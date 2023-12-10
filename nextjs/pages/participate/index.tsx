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
              <h1 className="text-2xl mb-2">Invest into Commodities</h1>
              <form className="flex flex-col gap-4 w-[30vw] form-control">
                <div className="flex flex-col gap-1">
                  <label className="text-sm text-left ml-2">Invoice No.</label>
                  <input type="text" className="input input-bordered" placeholder="Enter Invoice No." />
                </div>
                <div className="flex flex-col gap-1">
                  <label className="text-sm text-left ml-2">Trade Id</label>
                  <input type="text" className="input input-bordered" placeholder="Enter Trade No." />
                </div>
                <div className="flex flex-col gap-1">
                  <label className="text-sm text-left ml-2">Required Amount</label>
                  <input
                    type="text"
                    className="input input-bordered"
                    value={"3000 USDC"}
                    placeholder="Required Amount"
                  />
                </div>
                <div className="flex flex-col gap-1">
                  <label className="text-sm text-left ml-2">Investment Amount</label>
                  <input type="text" className="input input-bordered" placeholder="Enter Investment Amount" />
                </div>
                <div className="flex justify-center">
                  <button className="btn btn-primary">Join Trade</button>
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
