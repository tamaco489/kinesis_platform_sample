# Kinesis Platform Sample


## Reference
[Amazon Kinesis Data Streams (KDS) について](https://zenn.dev/tamaco489/scraps/f16d362708aa3b)

## 📚 Documentation

This project includes comprehensive documentation for the serverless application architecture using Amazon Kinesis Data Streams.

#### 🏛️ Architecture Diagrams

**Infrastructure Architecture**
![Infrastructure Architecture](docs/architecture/infra_architecture.png)

#### 🔄 Sequence Flow Diagrams

**Command Processing Flow**
![Command Processing Flow](docs/sequence_flow/command_processing_flow.png)

**Query Processing Flow**
![Query Processing Flow](docs/sequence_flow/query_processing_flow.png)

**Product Purchase Flow**
![Product Purchase Flow](docs/sequence_flow/product_purchase_flow.png)


### 🔧 Technology Stack

- **AWS Lambda** - Serverless compute
- **Amazon Kinesis Data Streams** - Event streaming
- **Amazon Kinesis Data Firehose** - Data transformation and delivery
- **Amazon DynamoDB** - State storage
- **Amazon Aurora** - Formatted data store
- **Amazon S3** - Archive and analytics storage
- **AWS API Gateway** - REST/HTTP API endpoints

### 📖 Design Patterns

- **CQRS (Command Query Responsibility Segregation)**
- **Event Sourcing**
- **Serverless Architecture**
- **Event-Driven Design**

