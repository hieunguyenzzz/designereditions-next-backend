import { 
  ExecArgs,
} from "@medusajs/framework/types"

export default async function helloWorld({
  container,
  args
}: ExecArgs) {
  console.log("Hello World!")
  
  if (args.length) {
    console.log(`You passed these arguments: ${args.join(", ")}`)
  }
} 