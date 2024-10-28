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

#### Data Model

The first step is represent the TDs in the PostgreSQL database. We are using the following schema for that:

<img width="860" alt="image" src="https://github.com/user-attachments/assets/32d2a478-e249-467e-ac27-2adc6773d008">

The TDs are stored in the table "thing" along with the child tables "property" and "action". The table registry is used to store the addresses of the registries. The next step is to load the data. The platform allows to express this extract-load-transform process using JSONata (https://jsonata.org/) with some extensions for accessing REST services and databases (https://dashjoin.github.io/platform/latest/developer-reference/#dashjoin-expression-reference).

Loading all TDs from the registry can be done using the following code:

```
$all("wot", "registry").href.
  $curl("GET", $, {}, {})
```

The resulting list of TDs can then be mapped into the DB schema using mapping expression like the following one:

```
{
    {
      "thing": $id,
      "name": $k,
      "description": $v.description,
      // TODO: currently limited to HTTP
      // if only other protocols are offered, we should replace the href with that of the API gateway
      "href": $replace(forms[$."contentType" = "application/json"].href[$contains($, "http")], /\{.*\}/, ""),
      "vars": $vars ? $vars : uriVariables,
      "input": input,
      "output": output
    }
  }
```

This expression collects the action's JSON Schema from either the uriVariables or the "input" fields. Note that the platform offers a streaming mode to support importing large sets of TDs (https://dashjoin.github.io/platform/latest/developer-reference/#etl).

#### Security

TODO

#### Semantic Data Harmonization

TODO

#### Generic Properties and Actions

TODO: mapping
TODO: security

The user interface for displaying device properties makes use of the platform's display widget. It is placed in a container that shows a widget for every device property. The widget simply displays the result of the HTTP request to the device WoT API. The device href is obtained from the foreach loop variable "value" which in turn is read from the database by looking up all properties of the current thing:

```
{
  "display": "$curl('GET', value.href)",
  "widget": "display"
}
```

<img width="809" alt="image" src="https://github.com/user-attachments/assets/a2471909-b1b0-4f09-be0e-a1a07f777968">

The screenshot above shows a form that gathers data for performing an action. Wot Manager makes use of the JSON Schema descriptions found in the TDs. These can be fed directly into the platform's button widget, describing the form to display to the user. Note that the form tooltips and select values are taken directly from the JSON Schema property descriptions and type enums respectively. The form also automatically performs any input validation defined in the schema. In this example, some inputs are required to be present. The definition of the button widget is as follows:

````
// TODO: POST ist hard coded
{
  "print": "($curl('POST', value.href & $call('template', form), form); $refresh();)",
  "schemaExpression": "value.vars ? {'properties': value.vars} : value.input",
  "title": "${value.name}",
  "widget": "button"
}
```

The field schemaExpression specifies a JSONata expression to compute the JSON Schema for the form. The field "print" specifies the action to perform when the button is pressed. We perform two command. First, the action is performed. The call to the template subrouting helps to handle cases where the inputs are provided as URI variables. The call to refresh triggers the UI to redraw itself, getting potentially updated device values in the process, e.g. the water level being lower after a becerage was brewed.

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

