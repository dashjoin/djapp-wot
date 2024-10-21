# AI Enabled WoT Management 

## Introduction 

* W3C Web of Things (WoT) aims at countering the fragmentation in the IoT space by using and extending existing, standardized Web technologies 
* Several tools and SDKs are available (https://www.w3.org/WoT/developers/) 
* Related work: https://arxiv.org/pdf/1910.04617 
* We present a generic WoT manager with the following features: 
  * Connect to any device of the box 
  * Semantically harmonize their data and show comprehensive dashboards 
  * Allow users to trigger actions on the devices 
  * Enable AI empowered workflows to achieve user goals 

## Wot Manager 

### Features 

* Discovery: connect to one or more WoT registries 
* Security and authorization: Wot Manager allows providing credentials for the devices and leverages OpenID and RBAC to empower users 
* Semantic data harmonization: TODO 
* Dashboarding on the harmonized data 
* Trigger device actions via generic JSON Schema forms 
* Trigger actions via natural language using LLM text to JSON features 
* Solve complex goals using LLM tools 

### Architecture 

* OpenID connector to IDM 
* RBAC enabled database to store and query TDs 
* Credential manager to store thing secrets 
* JSON stack to process OpenAPI, JSON Schema 
* API gateway to support non web protocols 

### Implementation 

* Leverage Low Code platform 
* Can be extended easily 
* Install custom add-ons via apps 

## Use Cases 

* Home automation to showcase dynamic forms 
* Building management to showcase data harmonization 
* Smart city to showcase speech and AI planning features (catching a bus in a foreign city) 

## Conclusion 

TODO


# Generic Management of Web of Things based on JSON Schema

## Introduction 

The goal of the project is to showcase the benefits of an WoT enabled world: 

* The use of declarative specifications and reusable vocabularies enables any device to the managed seamlessly 
* Higher level tasks such as energy management or physical building security can be realized by combining generic capability specifications with AI 

## Team 

* Ege Korkan, Siemens 
* Andreas Eberhart, Dashjoin 

## Project Scope 

We will develop a WoT management system with the following features: 

* Connect to a WoT registry 
* Ability to browse / search all WoT devices 
* Ability to display all device data and call device APIs from user forms (dynamically rendered using JSON Schema) 
* Generic dashboards showing charts for common device status 
* OpenAI tool to allow users to interact with WoT devices using natural language (https://platform.openai.com/docs/assistants/tools/function-calling) 

