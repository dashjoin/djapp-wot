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

#### Semantic Data Harmonization

WoT makes heavy use of semantically annotated JSON-LD. An implicit benefit of this technology is the ability to "understand" data. This allows WoT manager to map syntactically different but semantically similar data from devices onto a common information model.

#### Visualization

Once device data is aligned to a common model, it can be visualized accordingly. WoT Manager offers comprehensive charts fed from data received from heterogeneous devices.

#### Automation

Besides visualization, a second benefit of a common information model is the ability to perform actions on different devices. Let's assume we would like to dim all lights to 50%, but the lights require this action to be triggered in a slightly different way. This can be achieved by mapping the semantic intention to the concrete call syntax, just like we do for incoming property data.

#### Natural Language Commands

WoT Manager offers traditional forms for triggering device actions. To make things more usable, for instance in a smart home setting, WoT manager also provides natural language commands.

#### AI Planning

Taking natual language commands a step further, WoT manager makes use of modern LLM's planning capabilities. A user can specify a goal in natural language. In turn, the system will figure out a way to accomplish this goal by invoking device actions.

### Architecture 

<img width="1449" alt="image" src="https://github.com/user-attachments/assets/88d14ca8-5557-4859-89ee-8617cdbc010b">

This figure describes the WoT manager architecture. We see the following components:

* The core application is built using the Dashjoin Low Code platform (https://github.com/dashjoin/platform). The main motivation for this approach is the ability to quickly customize the generic management features with more specialized domain specific features. The platform consists of a horizonally scalable set of application servers and a shared configuration database that holds the application itself. Technically, this is a clone of the WoT Manager GIT repository (https://github.com/dashjoin/djapp-wot).
* OpenID capable IDM: The IDM is used to authenticate users accessing the WoT Manager. Any OpenID capable IDM can be used. The platform maps claims associated to the user in the IDM to platform roles, which in turn grant the user access to devices and device actions.
* On top of the platform are the user interface as well as a REST API allowing 3rd party integrations.
* The TDs are stored in a PostgrSQL database. Note that the platform also supports RDF stores that would enable SPARQL queries over the device descriptions.
* The platform uses an LLM for the natural language and planning use cases. The LLM tool integration is done using the Python SDK avaiable in Dashjoin Studio.
* The device connectivity uses RESTful APIs. We leverage APIs bridges to make other protocols like MQTT or COAP available via HTTP.
* The RBAC (https://dashjoin.github.io/platform/latest/security/#access-control) and credential manager (https://dashjoin.github.io/platform/latest/developer-reference/#credentials) are part of the platform.
* The mapping component sits between the platform and the device APIs

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

