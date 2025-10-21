#!/usr/bin/env node

async function promptGpt(message) {
  let body = JSON.stringify({
    model: "openai",
    stream: false,
    temperature: 1,
    top_p: 1,
    messages: [
      { role: "system", content: "Your are a helpful assistant that provides brief responses unless asked for more details." },
      { role: "user", content: message }
    ]
  })
  let response = await fetch('https://text.pollinations.ai/openai', {
    method: 'POST',
    headers: {
      'Accept': 'application/json',
      'Content-Type': 'application/json'
    },
    body
  });
  if (!response.ok) {
    throw new Error(`HTTP error! status: ${response.status}`);
  }
  let data = await response.json();
  return data.choices[0].message.content;
}

async function trick17(args) {
  const getStdin = async () => {
    const chunks = [];
    for await (const chunk of process.stdin) chunks.push(chunk);
    return Buffer.concat(chunks).toString();
  };

  let stdin = await getStdin();
  //console.log("Received stdin:", stdin);
  console.log(await promptGpt(`${args.join(' ')}\n${stdin}`));
}

async function main() {
  let args = process.argv.slice(2);
  if (args.length === 0) {
    console.log("No arguments provided. Exiting.");
    return;
  }
  trick17(args);
}

await main();
