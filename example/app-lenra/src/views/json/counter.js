import { Counter } from "../../classes/Counter.js";

export default function ([counter], _props) {
  return {
    value: counter.count,
    onIncrement: {
      type: "listener",
      action: "increment",
      props: {
        id: counter._id
      }
    }
  };
}
