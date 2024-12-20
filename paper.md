# Generic and Extensible Web of Things Manager Using JSON Schema & AI

[Andreas Eberhart](https://www.linkedin.com/in/andreas-eberhart-94264a44/), [Dashjoin](https://dashjoin.com/)  
[Ege Korkan](https://www.linkedin.com/in/ege-korkan/), [Siemens](https://www.siemens.com/)

## Introduction

Internet of Things (IoT) describes applying internet technology to devices in homes, factories, or smart cities. Obviously, this space offers tremendous potential for applications like energy management, predictive maintenance, and many more. With IoT being such a wide field, many different vendors are active in it, offering their own platforms, protocols and specifications. The Web of Things (WoT) standards by the World Wide Web Consortium (W3C) aims at overcoming the interoperability challenge resulting from this diversity, where the core Thing Description (TD) specification allows describing protocol interfaces of any IoT device with any protocol.

Consider this [sample TD](http://plugfest.thingweb.io/http-advanced-coffee-machine). It lists a [JSON-LD](https://json-ld.org/) context, device type, description, and security definitions.

```
 "@context": [
    "https://www.w3.org/2019/wot/td/v1",
    "https://www.w3.org/2022/wot/td/v1.1",
    {
      "@language": "en"
    }
  ],
  "@type": "Thing",
  "title": "http-advanced-coffee-machine",
  "securityDefinitions": {
```

This is followed by properties, actions, and events. Properties describe the device sensors by specifying how to query the sensor via a web form and what kind of data to expect via a JSON Schema:

```
  "properties": {
    "allAvailableResources": {
      "type": "object",
      "description": "Current level of all available resources given as an integer percentage for each particular resource.\\nThe data is obtained from the machine's sensors but can be set manually via the availableResourceLevel property in case the sensors are broken.",
      "readOnly": true,
      "properties": {
        "water": {
          "type": "integer",
          "minimum": 0,
          "maximum": 100
        },
        ...
      },
      "forms": [
        {
          "href": "http://plugfest.thingweb.io:80/http-advanced-coffee-machine/properties/allAvailableResources",
          "contentType": "application/json",
          "op": [
            "readproperty"
          ],
          "htv:methodName": "GET"
        },
```

Actions describe device functionality that can be called from a client. Events are asynchronous calls from the device back to the client.

Several [WoT SDKs and tools](https://www.w3.org/WoT/developers/) are already available. We are specifically interested in applications that make use of WoT’s generic nature. This means that rather than building a solution for one application area, we want the solution to be able to provide value on top of any WoT device. This concept was introduced by [Sciullo et al](https://arxiv.org/pdf/1910.04617), and it allows for any WoT device to be connected to a management system. The system displays the device properties and displays generic forms for conveniently invoking device actions. We build on their ideas and extend them, specifically by introducing security, semantic mappings, and the ability to leverage artificial intelligence to interact with arbitrary devices more easily.

### Features

In this paper we present WoT Manager. It is a generic platform for managing any WoT device. Specifically, it offers the following features:

* **Discovery**: An important part of the WoT stack is the ability to [discover devices in a registry](https://www.w3.org/TR/wot-discovery/). Given credentials and addresses, WoT Manager can connect to several registries.

* **Security**: Security is a crucial aspect of IoT applications, specifically when actions such as opening doors or machine valves are concerned. The [WoT architecture document](https://www.w3.org/TR/wot-architecture10/#security) references well-known web security protocols which WoT Manager supports.

* **Semantic Data Harmonization**: WoT makes heavy use of semantically annotated JSON-LD. An implicit benefit of this technology is the ability to "understand" data. This allows WoT Manager to map syntactically different but semantically similar data from devices onto a common information model.

* **Visualization**: Once device data is aligned into a common model, it can be visualized accordingly. WoT Manager offers comprehensive charts fed from data received from heterogeneous devices.

* **Incorporating Background Knowledge**: WoT Manager can be augmented with background information about the Things. This might be specification information gathered off the device's datasheet or information about the thing from an asset management system (e.g. the location of a thing on a factory shopfloor). This makes it possible to include this background knowledge in visualizations, for instance, showing the power consumption per building floor.

* **Automation**: Besides visualization, a second benefit of a common information model is the ability to perform actions on different devices. Let's assume we would like to dim all lights to 50%, but the lights require this action to be triggered in a slightly different way. This can be achieved by mapping the semantic intention to the concrete call syntax, just like we do for incoming property data.

* **Natural Language Commands**: WoT Manager offers traditional forms for triggering device actions. To make Things more usable, for instance in a smart home setting, WoT Manager also provides natural language commands.

* **AI Planning**: Taking natural language commands a step further, WoT manager makes use of modern LLM's planning capabilities. A user can specify a goal in natural language. In turn, the system will figure out a way to accomplish this goal by invoking device actions.

## Architecture

![image](https://github.com/user-attachments/assets/90a9cfd5-38cd-41b4-b772-97c2132bc655)

This figure describes the WoT Manager architecture. We see the following components:

* The core application is built using the [Dashjoin Low Code platform](https://github.com/dashjoin/platform). The main motivation for this approach is the ability to quickly customize the generic management features with more specialized domain specific features. The platform consists of a horizontally scalable set of application servers and a shared config database that holds the application itself. Technically, this is a clone of the [WoT Manager GIT repository](https://github.com/dashjoin/djapp-wot).
* OpenID capable IDM: The Identity Management (IDM) is used to authenticate users accessing the WoT Manager. Any OpenID capable IDM can be used. The platform maps claims associated to the user in the IDM to platform roles, which in turn grant the user access to devices and device actions.
* On top of the platform are the user interface as well as a REST API allowing 3rd party integrations.
* The TDs are stored in a PostgreSQL database. Note that the platform also supports RDF stores that would enable SPARQL queries over the device descriptions.
* The platform uses an LLM for the natural language and planning use cases. The LLM tool integration is done using the Python SDK available in Dashjoin Studio.
* The device connectivity uses RESTful APIs. We leverage APIs bridges to make other protocols like MQTT or COAP available via HTTP.
* The [RBAC](https://dashjoin.github.io/platform/latest/security/#access-control) and [credential manager](https://dashjoin.github.io/platform/latest/developer-reference/#credentials) are part of the platform.
* The mapping component sits between the platform and the device APIs

## Implementation

In this section, we describe the implementation of the features using the architecture presented above. The platform uses [JSONata](https://jsonata.org/) to express application logic in a concise way. JSONata is a functional query and transformation language for JSON data. The platform extends JSONata with a number of [custom functions](https://dashjoin.github.io/platform/latest/developer-reference/#dashjoin-expression-reference) for accessing databases, REST services, and many other features.

### Data Model

The first step is to represent the TDs in the PostgreSQL database. We are using the following schema for that:

![image](https://github.com/user-attachments/assets/9a56672f-f2c4-4cde-9e00-22d1bf6f74c0)

The TDs are stored in the table **thing** along with the child tables **property**, **event** and **action**. These four tables hold the information loaded from the registries. In addition, the **thing** table has the columns **credentials** and **role**, which define how devices are being accessed and how users are authorized for devices. The table registry is used to store the addresses of the registries. The table **saref:LightSwitch** represents tables that are created for any [WoT semantic annotation](https://www.w3.org/TR/wot-thing-description/#semantic-annotations). These tables are used to drive dashboards over multiple devices of the same type.

### Security and Access Control

When managing multiple devices, there are two principal approaches:

* Impersonation: WoT Manager leverages an identity management system (IDM) in conjunction with role-based access control (RBAC) to authenticate and authorize a user on a device. The actual call is being made using the device credentials. These are stored in the WoT Manager and are not known to the users
* Direct use: User knows secrets to access a device. WoT Manager does not manage any secrets and only passes calls along

We choose the impersonation approach. An administrator setting up the system will discover and configure the devices. In practice, this could be a shop floor manager in a factory or an electrician configuring a smart home. End users simply authenticate via OpenID. The authorization for individual devices is managed via the platform RBAC as described below.

The platform can securely store [credentials](https://dashjoin.github.io/platform/latest/developer-reference/#credentials). The WoT specification allows defining security descriptions for the thing or for individual actions, properties, and events. The system currently supports security only on the Thing level. This is achieved by defining credential sets and referencing them by id from the thing table. Any call performed from WoT Manager can be authenticated by reading the credential name and attaching this name to the curl HTTP header (the platform in turn looks up the secret from the credential store):

```
$credential = $read("wot", "thing", id).credential;
$curl(..., $credential ? {"Authorization": $credential} : {});
```

### Role Based Access Control

Since WoT Manager impersonates the users when communicating with the devices, we need to make sure that access control is enforced in the system. This is realized by associating device credentials with a system role. This means that only users in that role are allowed to use the credentials. The system also restricts user access to Things they are not allowed to access by introducing a role column on the things table. When querying the things table, the system only returns those rows where the role column has a role the current user is in.

### Discovery

When setting up Wot Manager, the various registries can be entered in the corresponding table. Technically, a registry provides a list of TDs. Note that some Things also publish their own TD. We treat these devices as device plus a mini registry. Loading all TDs from the registry can be done using the following code:

```
/* load all registries and iterate over them */
$all("wot", "registry").
  /* make a curl request to get the TDs (optionally consider required authorization) */
  $curl("GET", href, {}, credential ? {"Authorization": credential} : {})
```

The resulting list of TDs can then be mapped into the DB schema using mapping expression like the following one:

```
{
    {
      "thing": $id,
      "name": $k,
      "description": $v.description,
      /* currently limited to HTTP. If only other protocols are offered, replace the href with that of the API gateway */
      "href": $replace(forms[$."contentType" = "application/json"].href[$contains($, "http")], /\{.*\}/, ""),
      "vars": $vars ? $vars : uriVariables,
      "input": input,
      "output": output
    }
  }
```

This expression collects the action's JSON Schema from either the uriVariables or the "input" fields. Note that the platform offers a [streaming mode](https://dashjoin.github.io/platform/latest/developer-reference/#etl) to support importing large sets of TDs.

### Generic Properties and Actions

The user interface for displaying device properties makes use of the platform's display widget. It is placed in a container that shows a widget for every device property. The widget simply displays the result of the HTTP request to the device WoT API. The device `href` is obtained from the foreach loop variable "value" which in turn is read from the database by looking up all properties of the current thing. Finally, the authorization header is obtained via the mechanism described in the security section:

```
(
  $c := $read("wot", "thing", value.thing).credentials;
  $curl("GET", value.href, {}, $c ? {"Authorization": $c} : {})
)
```

<img width="809" alt="image" src="https://github.com/user-attachments/assets/a2471909-b1b0-4f09-be0e-a1a07f777968">

The screenshot above shows a form that gathers data for performing an action. WoT Manager makes use of the JSON Schema descriptions found in the TDs. These can be fed directly into the platform's button widget, describing the form to display to the user. Note that the form tooltips and select values are taken directly from the JSON Schema property descriptions and type enums respectively. The form also automatically performs any input validation defined in the schema. In this example, some inputs are required to be present. The definition of the button widget is as follows:

```
{
  "print": "($curl('POST', value.href & $call('template', form), form); $refresh();)",
  "schemaExpression": "value.vars ? {'properties': value.vars} : value.input",
  "title": "${value.name}",
  "widget": "button"
}
```

The field "schemaExpression" specifies a JSONata expression to compute the JSON Schema for the form. The field "print" specifies the action to perform when the button is pressed. We perform two commands. First, the action is performed. The call to the template subroutine helps to handle cases where the inputs are provided as URI variables. The call to "refresh" triggers the UI to redraw itself, getting potentially updated device values in the process, e.g. the water level being lower after a beverage was brewed.

### Semantic Data Harmonization

WoT uses semantic annotations to describe Things by associating them with a concept via the **@type** field. Consider the following annotation:

```
    "@context": [
        "https://www.w3.org/2022/wot/td/v1.1",
        { "saref": "https://w3id.org/saref#" }
    ],
    "title": "MyLampThing",
    "@type": "saref:LightSwitch",
```

It states that the thing is a light switch as standardized by the [Smart Applications REFerence Ontology](https://saref.etsi.org/) (SAREF). Having this annotation allows us to group Things into homogeneous categories and visualize an entire category on a dashboard rather than just a single thing. For instance, we might want to compute the percentage of lights being turned on in a building.

Since these kinds of dashboards are naturally driven by database queries, we materialize the thing properties in a set of tables, one table for each **@type** we encounter:

```
(
  /* only query data that is accessible w/o credentials to avoid having to secure the data and dashboards */
  $things := $all("wot", "thing")[credentials = null].
  ( 
    /* for each thing, get its properties */
    $id := id;
    $ ~> | $ | {"x": $all("wot", "property")[thing = $id].{ "id": $id, name : $curl("GET", href) }} |
  ){
    /* group by type */
    `type`: x
  }
)
```

We can use the platform's [Analytics Widget](https://dashjoin.github.io/platform/latest/developer-reference/#analytics) to easily display tables over this data and to expose filters (e.g. only show Things on a certain floor).

<img width="960" alt="image" src="https://github.com/user-attachments/assets/22f6989c-3958-492c-8660-d37067ee94af">

So far so good. But in the real world, Things of the same type might return data in a slightly different format or use a different property name. Consider the following example of three Things reporting the current power consumption as:

```
{
  "watt": 42
}

{
  "power": {
    "amount": 0.042,
    "unit": "kW"
  }
}

{
  "power": {
    "amount": 42,
    "unit": "W"
  }
}
```

In this scenario, we need a small piece of mapping code. Luckily, JSONata is perfect for this task:

```
{
    "watt": watt ? watt : power.amount * (power.unit = 'kW' ? 1000 : 1)
}
```

This mapping is introduced in the loading procedure described in the beginning of this section. Note that we can add any other field mapping required for other devices in the expression above. If the field's value evaluates to undefined (i.e. neither the watt nor power fields are present in the input), the key is omitted altogether.

### Incorporating Background Knowledge

There are some use cases that require additional information beyond the data we receive from WoT properties.

The device is likely to report its serial number or a device type. However, additional information about the type might not be included. This is typically found in datasheets that contain general product information. Consider this datasheet of a Siemens [Smart Home Energy Monitor](https://cache.industry.siemens.com/dl/files/239/109973239/att_1293296/v1/SIE_DS_InhabEM.pdf). It specifies aspects like the minimum and maximum temperature the device can be operated under or that the Max Voltage Sensing is 264VAC L-N per channel. This background is typically provided by the device vendor.

Along the same lines, the device might not be aware of the exact location it is installed in or whom to contact in case of an alert. This data is specific to the installation and can be found in building plans, asset management systems or bill of material databases.

WoT Manager allows us to join this data on a common identifier which typically is the WoT device ID. Our demonstrator links energy sensors to a table denoting the floor where the sensor is installed via the following query:

```
SELECT
  "saref:Sensor"."id", "saref:Sensor"."status", floor, "datasheet"."minTemp", "datasheet"."maxTemp"
FROM
  "saref:Sensor", "assets", datasheet
WHERE
  id = assets."ID" AND datasheet."ID" = datasheet
ORDER BY
  floor
```

Based on this query, we can easily visualize tables and charts with different aggregations and filters.

![image](https://github.com/user-attachments/assets/85074a89-d9be-4890-96a9-e7f6ec61b00d)

### Natural Language Commands

![image](https://github.com/user-attachments/assets/371fa9d1-1b07-4652-8e3e-236eff1cb050)

We're taking the form-based invocation a step further by introducing natural language commands. This feature takes advantage of the structured output mode of modern large language models. The following listing shows the configuration of the button widget. Rather than displaying a JSON Schema form corresponding to the action inputs, the widget shows a single text input that also allows voice inputs.

```
{
    "widget": "button",
    "schema": {
        "type": "object",
        "properties": {
            "Command": {
                "widget": "voice"
            }
        }
    },
    "print": see listing below,
    "text": "Brew"
}
```

The following code shows the call to the large language model (LLM). The [JSON mode](https://platform.openai.com/docs/guides/structured-outputs) is activated by using the `response_format` of type `json_schema`. This mode also makes it possible to specify a target schema that should be populated by the LLM. We query this schema from the WoT database using the expression `$all("wot", "action")[name="makeDrink"].vars`. The LLM output is fed into the `parseJson` function and stored in the variable `x`. After the LLM completes, we call the device action and pass the parsed JSON payload into the call.

```
(
$x := $curl("POST", "https://api.openai.com/v1/chat/completions", {
    "model": "gpt-4o-2024-08-06",
    "messages": [
      {
        "role": "system",
        "content": "You extract a coffee order into JSON data."
      },
      {
        "role": "user",
        "content": form.Command
      }
    ],
    "response_format": {
      "type": "json_schema",
      "json_schema": {
        "name": "coffe_request_schema",
        "schema": {
            "type": "object",
            "properties": $all("wot", "action")[name="makeDrink"].vars,
            "additionalProperties": false
        }
      }
    }
  }, {"Authorization": "openai"}).choices.message[0].content ~> $parseJson($);

$setVariable("request", $x);
$curl("POST", "http://plugfest.thingweb.io:8083/smart-coffee-machine/actions/makeDrink", $x);
$refresh();
)
```

#### Planning

Large language models not only have the ability to extract structured information from a command but can also act as agents on behalf of the user and use external tools in order to achieve a goal. Since this process is much more complex than the information extraction shown in the previous section, we employ the [LlamaIndex](https://www.llamaindex.ai/) Python library. LlamaIndex streamlines the process of writing tools and making them available to a generic AI agent. Tools can be any [OpenAPI service](https://docs.llamaindex.ai/en/stable/api_reference/tools/openapi/) or any [Python function](https://docs.llamaindex.ai/en/stable/module_guides/deploying/agents/tools/#functiontool).

The textual tool and parameter metadata is critical in describing when to use a tool to the AI agent. Therefore, we do not rely on the WoT action descriptions alone. Instead, we require the administrator to explicitly define actions to be exposed to the AI in the platform's [function catalog](https://dashjoin.github.io/platform/latest/developer-reference/#functions).

These functions are wrapped in a Python function tool that exposes the action to the AI. If called, it also handles the authentication from the Python stack back to the platform. Consider the following pseudocode:

```
query the platform's function catalog
wrap functions in a LlamaIndex FunctionTool
register the functions with the LLM
call the LLM with the prompt obtained from the user
```

Consider the following example: In the evening, we would like to "turn off unused lights" in an office building. The LLM can plan and execute this task when given these tools:

```
Locking system: get a list of persons in the building
Directory service: get LDAP information about persons
Asset DB: get devices by room
Light action: turn lights off/on
```

Here is a sample trace:

```
> Running step 336b4b45-06c4-499f-8bf8-fbf59d943708. Step input: turn off lights in offices where people have gone home
Thought: The current language of the user is English. I need to use a tool to help me identify which offices have people who have gone home.
Action: lockingSystem
Action Input: {}
Observation: ['joe@emaple.org', 'mike@example.org']
> Running step 637db939-be6e-491a-9a7e-0b80a1498dcf. Step input: None
Thought: I have the list of people currently in the office building. I need to get directory information to determine which offices these individuals belong to.
Action: ldap
Action Input: {}
Observation: [{'email': 'joe@example.org', 'office': '12b'}, {'email': 'mike@example.org', 'office': '15'}, {'email': 'sarah@example.org', 'office': '4a'}]
> Running step 8608270f-5f1c-4b84-a74c-5a4946ee739d. Step input: None
Thought: I have the office information for each person. Joe is in office 12b, Mike is in office 15, and Sarah is in office 4a. Since Joe and Mike are still in the building, I need to turn off the lights in Sarah's office (4a) as she has gone home.
Action: assets
Action Input: {'office': '4a'}
Observation: [{'id': '35313-2426', 'type': 'light-switch'}, {'id': 'af425-f352', 'type': 'energy sensor'}]
> Running step f95c73ed-50a8-42e7-a5a5-aa2303b21cd2. Step input: None
Thought: I have identified the light switch asset in Sarah's office (4a) with the ID '35313-2426'. I will now proceed to turn off the light in that office.
Action: light
Action Input: {'id': '35313-2426', 'state': False}
Observation: None
> Running step c8d309f5-0a2b-4598-b153-a5dc6d81bfbc. Step input: None
Thought: I have successfully turned off the lights in Sarah's office (4a) as she has gone home. I can now provide the final response.
Answer: The lights in office 4a have been turned off as the occupant has gone home.
```

## Conclusion

In this paper we presented WoT Manager. A [demo version](https://wot.run.dashjoin.com/) is online for you to experiment. You can login with an existing Google user or by registering with any email address.

The key takeaway is twofold. First, leveraging a Low Code approach and standards like WoT and JSON Schema, the cost of developing a powerful and feature rich application is very low. WoT standardizes and simplifies the way to interact with devices. The Low Code platform allows us to use its powerful out of the box features such as role based access control or input forms driven by JSON Schema.

The second takeaway is that a solid basis of WoT actions and their metadata make it possible to interact with the devices in a generic way via large language models. LLMs can replace traditional client code with an intelligent layer that can interface with users in a more natural way.
