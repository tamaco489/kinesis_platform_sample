# Serverless Application Architecture

## Overall Architecture Diagram

```mermaid
%%{init: {'theme': 'base', 'themeVariables': { 'fontSize': '12px', 'fontFamily': 'arial' }}}%%
graph TB
    %% Client Layer
    Client["Client Web/Mobile"]
    
    %% API Gateway Layer
    APIGateway["API Gateway REST/HTTP API"]
    
    %% Lambda Layer
    Lambda["Unified Lambda Function<br/>Command + Query Integration"]
    
    %% Lambda Internal Processing
    subgraph LambdaInternal ["Lambda Internal Processing"]
        Command["Command Processing"]
        Query["Query Processing"]
        Router["Router<br/>Command/Query Routing"]
    end
    
    %% Data Store Layer
    DynamoDB[("DynamoDB<br/>State Storage")]
    Aurora[("Amazon Aurora<br/>Formatted Data")]
    
    %% Event Streaming Layer
    KinesisStream["Kinesis Data Streams"]
    KinesisFirehose["Kinesis Data Firehose"]
    S3[("Amazon S3<br/>Archive & Analytics")]
    
    %% Lambda Consumer
    LambdaConsumer["Lambda Consumer<br/>Kinesis Trigger"]
    
    %% External Services
    ExternalAPI["External Payment Provider<br/>Mock Execution"]
    
    %% Connections
    Client --> APIGateway
    APIGateway --> Lambda
    Lambda --> Router
    Router --> Command
    Router --> Query
    
    Command --> DynamoDB
    Command --> ExternalAPI
    Command --> KinesisStream
    
    Query --> Aurora
    
    KinesisStream --> KinesisFirehose
    KinesisFirehose --> S3
    KinesisStream --> LambdaConsumer
    LambdaConsumer --> Aurora
    
    %% Styles
    classDef client fill:#e1f5fe,stroke:#333,color:#000
    classDef gateway fill:#fff3e0,stroke:#333,color:#000
    classDef lambda fill:#f3e5f5,stroke:#333,color:#000
    classDef database fill:#e8f5e8,stroke:#333,color:#000
    classDef streaming fill:#fff8e1,stroke:#333,color:#000
    classDef external fill:#ffebee,stroke:#333,color:#000
    
    class Client client
    class APIGateway gateway
    class Lambda,Router,Command,Query,LambdaConsumer lambda
    class DynamoDB,Aurora,S3 database
    class KinesisStream,KinesisFirehose streaming
    class ExternalAPI external
```

## Processing Flow Details

### Command Processing Flow (State Changes)

```mermaid
sequenceDiagram
    participant C as Client
    participant AG as API Gateway
    participant L as Lambda
    participant D as DynamoDB
    participant E as External API
    participant K as Kinesis Streams
    participant F as Kinesis Firehose
    participant S3 as S3
    
    C->>AG: POST Request
    AG->>L: Request Forwarding
    L->>L: Router Processing<br/>Command Type Routing
    L->>D: State Storage<br/>Product Reservation, Purchase, etc.
    L->>E: External API Call<br/>Payment Processing, etc.
    E-->>L: Processing Result
    L->>K: Event Publishing<br/>(PutRecord)
    K->>F: Event Forwarding
    F->>S3: Event Log Recording<br/>For Athena Analytics
    L-->>AG: Response
    AG-->>C: Response
```

### Query Processing Flow (Reference)

```mermaid
sequenceDiagram
    participant C as Client
    participant AG as API Gateway
    participant L as Lambda
    participant A as Aurora
    
    C->>AG: GET Request
    AG->>L: Request Forwarding
    L->>L: Router Processing<br/>Query Type Routing
    L->>A: Data Retrieval<br/>Formatted Data
    A-->>L: Data
    L-->>AG: Response
    AG-->>C: Response
```

## Product Purchase Flow

```mermaid
graph LR
    subgraph "Shop API Lambda Function"
        A[1. Get Product List<br/>Query]
        B[2. Get Product Details<br/>Query]
        C[3. Reserve Product<br/>Command: POST /reservations]
        D[4. Confirm Purchase<br/>Command: POST /purchase]
    end
    
    subgraph "Shop Dispatch Lambda Function"
        E[1. Get Kinesis Event]
        F[2. Write Aggregated/Reference<br/>Information to Aurora]
        G[3. Record Event Log<br/>to Firehose]
    end
    
    A --> B
    B --> C
    C --> D
    D --> E
    E --> F
    E --> G
```

## Technology Stack

| Component | Technology | Role |
|---|---|---|
| **Frontend** | Web/Mobile | User Interface |
| **API Gateway** | AWS API Gateway | REST/HTTP API Endpoint |
| **Lambda** | AWS Lambda | Serverless Function (Command/Query Integration) |
| **Data Store** | DynamoDB | State Storage |
| **Database** | Amazon Aurora | Formatted Data Store |
| **Streaming** | Kinesis Data Streams | Event Streaming |
| **Data Pipeline** | Kinesis Data Firehose | Data Transformation & Delivery |
| **Storage** | Amazon S3 | Archive & Analytics Storage |
| **Analytics** | Amazon Athena | Data Analytics |

## Design Principles

1. **CQRS (Command Query Responsibility Segregation)**
   - Command Processing: State changes and event publishing
   - Query Processing: Data reference only

2. **Event Sourcing**
   - Record all state changes as events
   - Event streaming with Kinesis Data Streams

3. **Serverless Design**
   - No infrastructure management required
   - Auto-scaling

4. **Data Analytics Support**
   - Event log storage to S3
   - Analytics capability with Athena 