import { DataApi } from "@lenra/app-server";
import { views } from "./index.gen.js";
import { Counter } from "./classes/Counter.js";
import { View } from "@lenra/components";

export const lenraRoutes = [
  {
    path: "/",
    view: View(views.main)
  }
]

export const jsonRoutes = [
  {
    path: "/counter/me",
    view: View(views.json.counter).data(DataApi.collectionName(Counter), {
      "user": "@me"
    })
  }
]
