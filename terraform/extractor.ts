import * as outputfile from "./tf-outputs.json";

export function getTerraformOutput(key: string): any {
  return outputfile[key]?.value;
}
