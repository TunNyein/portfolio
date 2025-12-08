# **FULL GUIDE: S3 + API Gateway + Lambda + DynamoDB + CloudWatch Visitor Counter**

---

# **1️⃣ S3 STATIC WEBSITE (Your Existing Website)**

You already have this part. No changes required except adding a small JavaScript snippet later.

---

# **2️⃣ DynamoDB Table Setup**

Create a table:

**Table Name:** `visitor-counter`

**Partition Key:** `id` (String)

Insert one item manually:

```
id = "counter"
count = 0

```

---

# **3️⃣ Lambda Function (Node.js 20/22/24)**

This function will:

- Atomically increment counter
- Return updated count
- Log CloudWatch metrics

### **Create a Lambda Function**

Name: `visitor-counter-lambda`

Runtime: **Node.js 20.x**

Execution Role permissions:

- DynamoDB Read/Write
- CloudWatch Logs

### **Lambda Code (FINAL VERSION with CloudWatch Logs + Metrics)**

```jsx
import {
  DynamoDBClient
} from "@aws-sdk/client-dynamodb";
import {
  DynamoDBDocumentClient,
  UpdateCommand
} from "@aws-sdk/lib-dynamodb";
import {
  CloudWatchClient,
  PutMetricDataCommand
} from "@aws-sdk/client-cloudwatch";

const db = DynamoDBDocumentClient.from(new DynamoDBClient({}));
const cw = new CloudWatchClient({});

const TABLE = "visitor-counter";

export const handler = async (event) => {
  try {
    console.log("📌 Incoming request:", JSON.stringify(event));

    // Update counter atomically
    const result = await db.send(new UpdateCommand({
      TableName: TABLE,
      Key: { id: "counter" },
      UpdateExpression: "SET #c = if_not_exists(#c, :start) + :inc",
      ExpressionAttributeNames: { "#c": "count" },
      ExpressionAttributeValues: { ":inc": 1, ":start": 0 },
      ReturnValues: "UPDATED_NEW"
    }));

    const visits = result.Attributes.count;

    // Send custom metric to CloudWatch
    await cw.send(
      new PutMetricDataCommand({
        Namespace: "TunNyein/VisitorCounter",
        MetricData: [
          {
            MetricName: "PageViews",
            Value: 1,
            Unit: "Count"
          }
        ]
      })
    );

    console.log("📊 Updated visitor count:", visits);
    console.log("📈 CloudWatch metric sent");

    return {
      statusCode: 200,
      headers: {
        "Access-Control-Allow-Origin": "*"
      },
      body: JSON.stringify({ visits })
    };
  } catch (err) {
    console.error("❌ Error:", err);
    return {
      statusCode: 500,
      body: JSON.stringify({ error: "Internal server error" })
    };
  }
};

```

---

# **4️⃣ CloudWatch Setup (Metrics + Logs)**

This Lambda automatically creates:

### **📌 CloudWatch Logs**

- Every Lambda execution is logged to:
    
    ```
    /aws/lambda/visitor-counter-lambda
    
    ```
    

### **📌 CloudWatch Custom Metric**

Lambda sends:

```
Namespace: TunNyein/VisitorCounter
Metric: PageViews

```

You can create a dashboard to show:

- Daily visitors
- Hourly visitors
- Total page load events

---

# **5️⃣ API Gateway Setup**

### **Create a REST API**

Resource: `/counter`

Method: `GET`

Integration: **Lambda Proxy Integration → visitor-counter-lambda**

### **Enable CORS**

- Allow GET
- Allow  Origin
- Deploy API

Your final endpoint will look like:

```
https://xyz123.execute-api.ap-southeast-1.amazonaws.com/prod/counter

```

---

### Terraform module (deploy API Gateway + Lambda + DynamoDB)

This repository includes a reusable Terraform module at `modules/serverless` that provisions the API Gateway `/counter` resource, Lambda (Node.js 20.x), DynamoDB table (`visitor-counter`), and the necessary IAM role/policies (it references `lambda-policy.json`).

Quick steps to use the module:

1. Build your Lambda and place the ZIP at `lambda/visitor_counter.zip` (zip `index.js` and any node_modules required).
2. Update `terraform.tfvars` with your values (e.g., `prefix`, `environment`, `aws_profile`). The project defaults to `aws_region = "us-east-1"`.
3. Confirm backend is configured for Terraform Cloud (this repo has `backend.tf` set to organization `tunnyein`, workspace `portfolio`). Ensure the workspace is connected to your GitHub repo in Terraform Cloud.
4. Run:

```bash
terraform init    # initializes remote backend and modules
terraform plan
terraform apply
```

Module outputs (available after apply):

- `module.serverless.api_invoke_url` — full API URL for the counter endpoint.
- `module.serverless.dynamodb_table` — DynamoDB table name (visitor-counter).
- `module.serverless.lambda_function_name` — Lambda function name.

Example root module invocation (already present in `main.tf`):

```hcl
module "serverless" {
  source        = "./modules/serverless"
  prefix        = var.prefix
  environment   = var.environment
  aws_region    = var.aws_region
  lambda_filename = "visitor_counter.zip"
}
```

Notes:
- The module reads the inline IAM policy from `lambda-policy.json` to allow DynamoDB read/write and CloudWatch metric put.
- The API Gateway returned URL follows the pattern shown earlier and will be output as `api_invoke_url`.