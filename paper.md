# AI Enabled WoT Management 

## Introduction 

Internet of Things (IoT) describes applying internet technology to devices in homes, factories, or smart cities. Obviously this space offers tremendous potential for applications like energy management, predictive maintenance, and many more. With IoT being such a wide field, many different vendors are active in it. The W3C Web of Things (WoT) standard aims at overcoming the resulting interoperability challenge.

Several WoT SDKs and tools are already available (https://www.w3.org/WoT/developers/). We are specifically interested in applications that make use of WoT’s generic nature. This means that rather than building a solution for one application area, we want the solution to be able to provide value on top of any WoT device. This concept was introduced by Sciullo et al (https://arxiv.org/pdf/1910.04617). It allows for any WoT device to be connected. The system displays the device properties and displays generic forms for conveniently invoking device actions. We build on their ideas and extend them, specifically by introducing security, semantic mappings, and the ability to leverage artificial intelligence to interact with arbitrary devices more easily.

## Wot Manager 

### Features 

WoT Manager offers the following features:

#### Discovery

An important part of the WoT stack is the ability to discover devices in a registry (https://www.w3.org/TR/wot-discovery/). Given credentials and addresses, WoT Manager is able to connect to several registries. Technically, these provide a list of thing descriptions (TDs). Note that some things also publish their own TD. We treat these devices as device plus mini-registry.

#### Security

Security is a cruicial aspect of IoT applications, specifically when actions such as opening doors or machine valves are concerned. The WoT architecture document (https://www.w3.org/TR/wot-architecture10/#security) references well-known web security protocols. When managing multiple devices, there are two principle approaches:

* Impersonation: WoT manager leverages an identity management system (IDM) in conjunction with role based access control (RBAC) to authenticate and authorize a user on a device. The actual call is being made using the device credentials. These are stored in the WoT manager and are not known to the users
* Direct use: User knows secrets to access a device. WoT manager does not manage any secrets and only passes calls along

We choose the impersonation approach. An administrator setting up the system will discover and configure the devices. In practise, this could be a shop floor manager in a factory or an electrician configuring a smart home. End users simply authenticate via OpenID and have immediate access to all devices assigned to them by the configured RBAC.  


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

