{
  "$id": "https://cisco.com/fso/schemas/codex/workflow.json",
  "name": "workflow",
  "identifyingProperties" : [
    "/id"
  ],
  "displayNameGenerationMechanism" : "{{object.name}}",
  "allowObjectFragments": false,
  "allowedLayers": [
    "SOLUTION",
    "TENANT"
  ],
  "referenceQualifiers" : {
    "$.events[:].type" : [
      "/contracts/cloudevent"
    ]
  },
  "jsonSchema": {
    "$schema": "http://json-schema.org/draft-07/schema#",
    "description": "Serverless Workflow specification - workflow schema",
    "type": "object",
    "properties": {
      "id": {
        "type": "string",
        "description": "Workflow unique identifier",
        "minLength": 1
      },
      "key": {
        "type": "string",
        "description": "Domain-specific workflow identifier",
        "minLength": 1
      },
      "name": {
        "type": "string",
        "description": "Workflow name",
        "minLength": 1
      },
      "description": {
        "type": "string",
        "description": "Workflow description"
      },
      "version": {
        "type": "string",
        "description": "Workflow version",
        "minLength": 1
      },
      "annotations": {
        "type": "array",
        "description": "List of helpful terms describing the workflows intended purpose, subject areas, or other important qualities",
        "minItems": 1,
        "items": {
          "type": "string"
        },
        "additionalItems": false
      },
      "start": {
        "$ref": "#/definitions/startdef"
      },
      "specVersion": {
        "type": "string",
        "description": "Serverless Workflow schema version",
        "enum" : ["0.8"]
      },
      "expressionLang": {
        "const": "jsonata",
        "description": "Identifies the expression language used for workflow expressions",
        "minLength": 1
      },
      "timeouts": {
        "oneOf": [{
          "type": "string",
          "format": "uri",
          "description": "URI to a resource containing timeouts definitions (json or yaml)"
        }, {
          "type": "object",
          "description": "Workflow default timeouts",
          "properties": {
            "workflowExecTimeout": {
              "oneOf": [{
                "type": "string",
                "description": "Workflow execution timeout duration (ISO 8601 duration format). If not specified should be 'unlimited'",
                "minLength": 1
              }, {
                "type": "object",
                "properties": {
                  "duration": {
                    "type": "string",
                    "description": "Workflow execution timeout duration (ISO 8601 duration format). If not specified should be 'unlimited'",
                    "minLength": 1
                  },
                  "interrupt": {
                    "type": "boolean",
                    "description": "If `false`, workflow instance is allowed to finish current execution. If `true`, current workflow execution is abrupted.",
                    "default": true
                  },
                  "runBefore": {
                    "type": "string",
                    "description": "Name of a workflow state to be executed before workflow instance is terminated",
                    "minLength": 1
                  }
                },
                "additionalProperties": false,
                "required": ["duration"]
              }]
            },
            "stateExecTimeout": {
              "$ref": "#/definitions/eventstate/properties/timeouts/properties/stateExecTimeout"
            },
            "actionExecTimeout": {
              "$ref": "#/definitions/branch/properties/timeouts/properties/actionExecTimeout"
            },
            "branchExecTimeout": {
              "$ref": "#/definitions/branch/properties/timeouts/properties/branchExecTimeout"
            },
            "eventTimeout": {
              "$ref": "#/definitions/eventstate/properties/timeouts/properties/eventTimeout"
            }
          },
          "additionalProperties": false,
          "required": []
        }]
      },
      "errors": {
        "oneOf": [{
          "type": "string",
          "format": "uri",
          "description": "URI to a resource containing error definitions (json or yaml)"
        }, {
          "type": "array",
          "description": "Workflow Error definitions. Defines checked errors that can be explicitly handled during workflow execution",
          "items": {
            "type": "object",
            "properties": {
              "name": {
                "type": "string",
                "description": "Domain-specific error name",
                "minLength": 1
              },
              "code": {
                "type": "string",
                "description": "Error code. Can be used in addition to the name to help runtimes resolve to technical errors/exceptions. Should not be defined if error is set to '*'",
                "minLength": 1
              },
              "description": {
                "type": "string",
                "description": "Error description"
              }
            },
            "additionalProperties": false,
            "required": ["name"]
          },
          "additionalItems": false,
          "minItems": 1
        }]
      },
      "keepActive": {
        "type": "boolean",
        "default": false,
        "description": "If 'true', workflow instances is not terminated when there are no active execution paths. Instance can be terminated via 'terminate end definition' or reaching defined 'workflowExecTimeout'"
      },
      "metadata": {
        "type": "object",
        "description": "Metadata information",
        "additionalProperties": {
          "type": "string"
        }
      },
      "events": {
        "type": "array",
        "description": "Workflow CloudEvent definitions. Defines CloudEvents that can be consumed or produced",
        "items": {
          "type": "object",
          "properties": {
            "name": {
              "type": "string",
              "description": "Unique event name",
              "minLength": 1
            },
            "source": {
              "type": "string",
              "description": "CloudEvent source"
            },
            "type": {
              "type": "string",
              "description": "CloudEvent type",
              "enum" : [
                "contracts:cloudevent/platform:metric.enriched.v1",
                "contracts:cloudevent/platform:event.enriched.v1",
                "contracts:cloudevent/platform:trace.enriched.v1",

                "contracts:cloudevent/platform:association.observed.v1",
                "contracts:cloudevent/platform:entity.observed.v1",
                "contracts:cloudevent/platform:extension.observed.v1",
                "contracts:cloudevent/platform:measurement.received.v1",
                "contracts:cloudevent/platform:event.processed.v1"
              ]
            },
            "kind": {
              "type": "string",
              "enum": ["consumed", "produced"],
              "description": "Defines the CloudEvent as either 'consumed' or 'produced' by the workflow. Default is 'consumed'",
              "default": "consumed"
            },
            "dataOnly": {
              "type": "boolean",
              "default": true,
              "description": "If `true`, only the Event payload is accessible to consuming Workflow states. If `false`, both event payload and context attributes should be accessible "
            },
            "metadata": {
              "$ref": "#/properties/metadata",
              "description": "Metadata information"
            }
          },
          "additionalProperties": false,
          "if": {
            "properties": {
              "kind": {
                "const": "consumed"
              }
            }
          },
          "then": {
            "required": ["name", "source", "type"]
          },
          "else": {
            "required": ["name", "type"]
          }
        },
        "additionalItems": false,
        "minItems": 1
      },
      "functions": {
        "type": "array",
        "description": "Workflow function definitions",
        "items": {
          "type": "object",
          "properties": {
            "name": {
              "type": "string",
              "description": "Unique function name",
              "minLength": 1
            },
            "operation": {
              "type": "string",
              "description": "If type is `rest`, <path_to_openapi_definition>#<operation_id>. If type is `asyncapi`, <path_to_asyncapi_definition>#<operation_id>. If type is `rpc`, <path_to_grpc_proto_file>#<service_name>#<service_method>. If type is `graphql`, <url_to_graphql_endpoint>#<literal \\\"mutation\\\" or \\\"query\\\">#<query_or_mutation_name>. If type is `odata`, <URI_to_odata_service>#<Entity_Set_Name>. If type is `expression`, defines the workflow expression.",
              "minLength": 1
            },
            "type": {
              "type": "string",
              "description": "Defines the function type. Is either `rest`, `asyncapi, `rpc`, `graphql`, `odata`, `expression`, or `custom`. Default is `rest`",
              "enum": ["rest", "asyncapi", "rpc", "graphql", "odata", "expression", "custom"],
              "default": "rest"
            },
            "authRef": {
              "oneOf": [{
                "type": "string",
                "description": "References the auth definition to be used to invoke the operation",
                "minLength": 1
              }, {
                "type": "object",
                "description": "Configures both the auth definition used to retrieve the operation's resource and the auth definition used to invoke said operation",
                "properties": {
                  "resource": {
                    "type": "string",
                    "description": "References an auth definition to be used to access the resource defined in the operation parameter",
                    "minLength": 1
                  },
                  "invocation": {
                    "type": "string",
                    "description": "References an auth definition to be used to invoke the operation"
                  }
                },
                "additionalProperties": false,
                "required": ["resource"]
              }]
            },
            "metadata": {
              "$ref": "#/properties/metadata"
            }
          },
          "additionalProperties": false,
          "required": ["name", "operation"]
        },
        "additionalItems": false,
        "minItems": 1
      },
      "states": {
        "type": "array",
        "description": "State definitions",
        "items": {
          "anyOf": [{
            "title": "Event State",
            "$ref": "#/definitions/eventstate"
          }, {
            "title": "Operation State",
            "$ref": "#/definitions/operationstate"
          }, {
            "title": "Parallel State",
            "$ref": "#/definitions/parallelstate"
          }, {
            "title": "Switch State",
            "$ref": "#/definitions/switchstate"
          }, {
            "title": "ForEach State",
            "$ref": "#/definitions/foreachstate"
          }]
        },
        "additionalItems": false,
        "minItems": 1
      }
    },
    "required": ["id", "specVersion", "states"],
    "definitions": {
      "transition": {
        "oneOf": [{
          "type": "string",
          "description": "Name of state to transition to",
          "minLength": 1
        }, {
          "type": "object",
          "description": "Function Reference",
          "properties": {
            "nextState": {
              "type": "string",
              "description": "Name of state to transition to",
              "minLength": 1
            },
            "produceEvents": {
              "type": "array",
              "description": "Array of events to be produced before the transition happens",
              "items": {
                "type": "object",
                "$ref": "#/definitions/produceeventdef"
              },
              "additionalItems": false
            }
          },
          "additionalProperties": false,
          "required": ["nextState"]
        }]
      },
      "onevents": {
        "type": "object",
        "properties": {
          "eventRefs": {
            "type": "array",
            "description": "References one or more unique event names in the defined workflow events",
            "minItems": 1,
            "items": {
              "type": "string"
            },
            "uniqueItems": true,
            "additionalItems": false
          },
          "actionMode": {
            "type": "string",
            "enum": ["sequential", "parallel"],
            "description": "Specifies how actions are to be performed (in sequence or in parallel)",
            "default": "sequential"
          },
          "actions": {
            "type": "array",
            "description": "Actions to be performed if expression matches",
            "items": {
              "type": "object",
              "$ref": "#/definitions/action"
            },
            "additionalItems": false
          },
          "eventDataFilter": {
            "description": "Event data filter",
            "$ref": "#/definitions/eventdatafilter"
          }
        },
        "additionalProperties": false,
        "required": ["eventRefs"]
      },
      "action": {
        "type": "object",
        "properties": {
          "name": {
            "type": "string",
            "description": "Unique action definition name"
          },
          "functionRef": {
            "description": "References a function to be invoked",
            "$ref": "#/definitions/functionref"
          },
          "eventRef": {
            "description": "References a `produce` and `consume` reusable event definitions",
            "$ref": "#/definitions/eventref"
          },
          "subFlowRef": {
            "description": "References a sub-workflow to invoke",
            "$ref": "#/definitions/subflowref"
          },
          "actionDataFilter": {
            "description": "Action data filter",
            "$ref": "#/definitions/actiondatafilter"
          },
          "condition": {
            "description": "Expression, if defined, must evaluate to true for this action to be performed. If false, action is disregarded",
            "type": "string",
            "minLength": 1
          }
        },
        "additionalProperties": false,
        "oneOf": [{
          "required": ["functionRef"]
        }, {
          "required": ["eventRef"]
        }, {
          "required": ["subFlowRef"]
        }]
      },
      "functionref": {
        "type": "object",
        "description": "Function Reference",
        "properties": {
          "refName": {
            "type": "string",
            "description": "Name of the referenced function"
          },
          "arguments": {
            "type": "object",
            "description": "Function arguments/inputs"
          },
          "invoke": {
            "type": "string",
            "enum": ["sync", "async"],
            "description": "Specifies if the function should be invoked sync or async",
            "default": "sync"
          }
        },
        "additionalProperties": false,
        "required": ["refName"]
      },
      "eventref": {
        "type": "object",
        "description": "Event References",
        "properties": {
          "produceEventRef": {
            "type": "string",
            "description": "Reference to the unique name of a 'produced' event definition"
          },
          "consumeEventRef": {
            "type": "string",
            "description": "Reference to the unique name of a 'consumed' event definition"
          },
          "consumeEventTimeout": {
            "type": "string",
            "description": "Maximum amount of time (ISO 8601 format) to wait for the result event. If not defined it should default to the actionExecutionTimeout"
          },
          "data": {
            "type": ["string", "object"],
            "description": "If string type, an expression which selects parts of the states data output to become the data (payload) of the event referenced by 'produceEventRef'. If object type, a custom object to become the data (payload) of the event referenced by 'produceEventRef'."
          },
          "contextAttributes": {
            "type": "object",
            "description": "Add additional extension context attributes to the produced event",
            "additionalProperties": {
              "type": "string"
            }
          }
        },
        "additionalProperties": false,
        "required": ["produceEventRef"]
      },
      "subflowref": {
        "oneOf": [{
          "type": "string",
          "description": "Unique id of the sub-workflow to be invoked",
          "minLength": 1
        }, {
          "type": "object",
          "description": "Specifies a sub-workflow to be invoked",
          "properties": {
            "workflowId": {
              "type": "string",
              "description": "Unique id of the sub-workflow to be invoked"
            },
            "version": {
              "type": "string",
              "description": "Version of the sub-workflow to be invoked",
              "minLength": 1
            },
            "onParentComplete": {
              "type": "string",
              "enum": ["continue", "terminate"],
              "description": "If invoke is 'async', specifies how subflow execution should behave when parent workflow completes. Default is 'terminate'",
              "default": "terminate"
            },
            "invoke": {
              "type": "string",
              "enum": ["sync", "async"],
              "description": "Specifies if the subflow should be invoked sync or async",
              "default": "sync"
            }
          },
          "required": ["workflowId"]
        }]
      },
      "branch": {
        "type": "object",
        "description": "Branch Definition",
        "properties": {
          "name": {
            "type": "string",
            "description": "Branch name"
          },
          "timeouts": {
            "type": "object",
            "description": "State specific timeouts",
            "properties": {
              "actionExecTimeout": {
                "type": "string",
                "description": "Action execution timeout duration (ISO 8601 duration format)",
                "minLength": 1
              },
              "branchExecTimeout": {
                "type": "string",
                "description": "Branch execution timeout duration (ISO 8601 duration format)",
                "minLength": 1
              }
            },
            "required": []
          },
          "actions": {
            "type": "array",
            "description": "Actions to be executed in this branch",
            "items": {
              "type": "object",
              "$ref": "#/definitions/action"
            },
            "additionalItems": false
          }
        },
        "additionalProperties": false,
        "required": ["name", "actions"]
      },
      "eventstate": {
        "type": "object",
        "description": "This state is used to wait for events from event sources, then consumes them and invoke one or more actions to run in sequence or parallel",
        "properties": {
          "name": {
            "type": "string",
            "description": "State name"
          },
          "type": {
            "type": "string",
            "const": "event",
            "description": "State type"
          },
          "exclusive": {
            "type": "boolean",
            "const": true,
            "description": "If true consuming one of the defined events causes its associated actions to be performed. If false all of the defined events must be consumed in order for actions to be performed"
          },
          "onEvents": {
            "type": "array",
            "description": "Define the events to be consumed and optional actions to be performed",
            "items": {
              "type": "object",
              "$ref": "#/definitions/onevents"
            },
            "additionalItems": false
          },
          "timeouts": {
            "type": "object",
            "description": "State specific timeouts",
            "properties": {
              "stateExecTimeout": {
                "type": "string",
                "description": "Workflow state execution timeout duration (ISO 8601 duration format)",
                "minLength": 1
              },
              "actionExecTimeout": {
                "$ref": "#/definitions/branch/properties/timeouts/properties/actionExecTimeout"
              },
              "eventTimeout": {
                "type": "string",
                "description": "Timeout duration to wait for consuming defined events (ISO 8601 duration format)",
                "minLength": 1
              }
            },
            "required": []
          },
          "stateDataFilter": {
            "description": "State data filter",
            "$ref": "#/definitions/statedatafilter"
          },
          "transition": {
            "description": "Next transition of the workflow after all the actions have been performed",
            "$ref": "#/definitions/transition"
          },
          "end": {
            "$ref": "#/definitions/end",
            "description": "State end definition"
          },
          "metadata": {
            "$ref": "#/properties/metadata"
          }
        },
        "additionalProperties": false,
        "oneOf": [{
          "required": ["name", "type", "onEvents", "end"]
        }, {
          "required": ["name", "type", "onEvents", "transition"]
        }]
      },
      "operationstate": {
        "type": "object",
        "description": "Defines actions be performed. Does not wait for incoming events",
        "properties": {
          "name": {
            "type": "string",
            "description": "State name"
          },
          "type": {
            "type": "string",
            "const": "operation",
            "description": "State type"
          },
          "end": {
            "$ref": "#/definitions/end",
            "description": "State end definition"
          },
          "stateDataFilter": {
            "description": "State data filter",
            "$ref": "#/definitions/statedatafilter"
          },
          "actionMode": {
            "type": "string",
            "enum": ["sequential", "parallel"],
            "description": "Specifies whether actions are performed in sequence or in parallel",
            "default": "sequential"
          },
          "actions": {
            "type": "array",
            "description": "Actions to be performed",
            "items": {
              "type": "object",
              "$ref": "#/definitions/action"
            }
          },
          "timeouts": {
            "type": "object",
            "description": "State specific timeouts",
            "properties": {
              "stateExecTimeout": {
                "$ref": "#/definitions/eventstate/properties/timeouts/properties/stateExecTimeout"
              },
              "actionExecTimeout": {
                "$ref": "#/definitions/branch/properties/timeouts/properties/actionExecTimeout"
              }
            },
            "required": []
          },
          "transition": {
            "description": "Next transition of the workflow after all the actions have been performed",
            "$ref": "#/definitions/transition"
          },
          "metadata": {
            "$ref": "#/properties/metadata"
          }
        },
        "additionalProperties": false,
        "oneOf": [{
          "required": ["name", "type", "actions", "end"]
        }, {
          "required": ["name", "type", "actions", "transition"]
        }]
      },
      "parallelstate": {
        "type": "object",
        "description": "Consists of a number of states that are executed in parallel",
        "properties": {
          "name": {
            "type": "string",
            "description": "State name"
          },
          "type": {
            "type": "string",
            "const": "parallel",
            "description": "State type"
          },
          "end": {
            "$ref": "#/definitions/end",
            "description": "State end definition"
          },
          "stateDataFilter": {
            "description": "State data filter",
            "$ref": "#/definitions/statedatafilter"
          },
          "timeouts": {
            "type": "object",
            "description": "State specific timeouts",
            "properties": {
              "stateExecTimeout": {
                "$ref": "#/definitions/eventstate/properties/timeouts/properties/stateExecTimeout"
              },
              "branchExecTimeout": {
                "$ref": "#/definitions/branch/properties/timeouts/properties/branchExecTimeout"
              }
            },
            "required": []
          },
          "branches": {
            "type": "array",
            "description": "Branch Definitions",
            "items": {
              "type": "object",
              "$ref": "#/definitions/branch"
            },
            "additionalItems": false
          },
          "completionType": {
            "type": "string",
            "enum": ["allOf", "atLeast"],
            "description": "Option types on how to complete branch execution.",
            "default": "allOf"
          },
          "numCompleted": {
            "type": ["number", "string"],
            "minimum": 0,
            "minLength": 0,
            "description": "Used when completionType is set to 'atLeast' to specify the minimum number of branches that must complete before the state will transition."
          },
          "transition": {
            "description": "Next transition of the workflow after all branches have completed execution",
            "$ref": "#/definitions/transition"
          },
          "metadata": {
            "$ref": "#/properties/metadata"
          }
        },
        "additionalProperties": false,
        "oneOf": [{
          "required": ["name", "type", "branches", "end"]
        }, {
          "required": ["name", "type", "branches", "transition"]
        }]
      },
      "switchstate": {
        "type": "object",
        "description": "Permits transitions to other states based on data conditions",
        "properties": {
          "name": {
            "type": "string",
            "description": "State name"
          },
          "type": {
            "type": "string",
            "const": "switch",
            "description": "State type"
          },
          "stateDataFilter": {
            "description": "State data filter",
            "$ref": "#/definitions/statedatafilter"
          },
          "timeouts": {
            "type": "object",
            "description": "State specific timeouts",
            "properties": {
              "stateExecTimeout": {
                "$ref": "#/definitions/eventstate/properties/timeouts/properties/stateExecTimeout"
              }
            },
            "required": []
          },
          "dataConditions": {
            "type": "array",
            "description": "Defines conditions evaluated against state data",
            "items": {
              "type": "object",
              "$ref": "#/definitions/datacondition"
            },
            "additionalItems": false
          },
          "defaultCondition": {
            "description": "Default transition of the workflow if there is no matching data conditions. Can include a transition or end definition",
            "$ref": "#/definitions/defaultconditiondef"
          },
          "metadata": {
            "$ref": "#/properties/metadata"
          }
        },
        "additionalProperties": false,
        "required": ["name", "type", "dataConditions", "defaultCondition"]
      },
      "defaultconditiondef": {
        "type": "object",
        "description": "DefaultCondition definition. Can be either a transition or end definition",
        "properties": {
          "name": {
            "type": "string",
            "description": "The optional name of the default condition, used solely for display purposes"
          },
          "transition": {
            "$ref": "#/definitions/transition"
          },
          "end": {
            "$ref": "#/definitions/end"
          }
        },
        "additionalProperties": false,
        "oneOf": [{
          "required": ["transition"]
        }, {
          "required": ["end"]
        }]
      },
      "datacondition": {
        "oneOf": [{
          "$ref": "#/definitions/transitiondatacondition"
        }, {
          "$ref": "#/definitions/enddatacondition"
        }]
      },
      "transitiondatacondition": {
        "type": "object",
        "description": "Switch state data based condition",
        "properties": {
          "name": {
            "type": "string",
            "description": "Data condition name"
          },
          "condition": {
            "type": "string",
            "description": "Workflow expression evaluated against state data. Must evaluate to true or false"
          },
          "transition": {
            "description": "Workflow transition if condition is evaluated to true",
            "$ref": "#/definitions/transition"
          },
          "metadata": {
            "$ref": "#/properties/metadata"
          }
        },
        "additionalProperties": false,
        "required": ["condition", "transition"]
      },
      "enddatacondition": {
        "type": "object",
        "description": "Switch state data based condition",
        "properties": {
          "name": {
            "type": "string",
            "description": "Data condition name"
          },
          "condition": {
            "type": "string",
            "description": "Workflow expression evaluated against state data. Must evaluate to true or false"
          },
          "end": {
            "$ref": "#/definitions/end",
            "description": "Workflow end definition"
          },
          "metadata": {
            "$ref": "#/properties/metadata"
          }
        },
        "additionalProperties": false,
        "required": ["condition", "end"]
      },
      "foreachstate": {
        "type": "object",
        "description": "Execute a set of defined actions or workflows for each element of a data array",
        "properties": {
          "name": {
            "type": "string",
            "description": "State name"
          },
          "type": {
            "type": "string",
            "const": "foreach",
            "description": "State type"
          },
          "end": {
            "$ref": "#/definitions/end",
            "description": "State end definition"
          },
          "inputCollection": {
            "type": "string",
            "description": "Workflow expression selecting an array element of the states data"
          },
          "outputCollection": {
            "type": "string",
            "description": "Workflow expression specifying an array element of the states data to add the results of each iteration"
          },
          "iterationParam": {
            "type": "string",
            "description": "Name of the iteration parameter that can be referenced in actions/workflow. For each parallel iteration, this param should contain an unique element of the inputCollection array"
          },
          "batchSize": {
            "type": ["number", "string"],
            "minimum": 0,
            "minLength": 0,
            "description": "Specifies how many iterations may run in parallel at the same time. Used if 'mode' property is set to 'parallel' (default)"
          },
          "actions": {
            "type": "array",
            "description": "Actions to be executed for each of the elements of inputCollection",
            "items": {
              "type": "object",
              "$ref": "#/definitions/action"
            },
            "additionalItems": false
          },
          "timeouts": {
            "type": "object",
            "description": "State specific timeouts",
            "properties": {
              "stateExecTimeout": {
                "$ref": "#/definitions/eventstate/properties/timeouts/properties/stateExecTimeout"
              },
              "actionExecTimeout": {
                "$ref": "#/definitions/branch/properties/timeouts/properties/actionExecTimeout"
              }
            },
            "required": []
          },
          "stateDataFilter": {
            "description": "State data filter",
            "$ref": "#/definitions/statedatafilter"
          },
          "transition": {
            "description": "Next transition of the workflow after state has completed",
            "$ref": "#/definitions/transition"
          },
          "mode": {
            "type": "string",
            "enum": ["sequential", "parallel"],
            "description": "Specifies how iterations are to be performed (sequentially or in parallel)",
            "default": "parallel"
          },
          "metadata": {
            "$ref": "#/properties/metadata"
          }
        },
        "additionalProperties": false,
        "oneOf": [{
          "required": ["name", "type", "inputCollection", "actions", "end"]
        }, {
          "required": ["name", "type", "inputCollection", "actions", "transition"]
        }]
      },
      "startdef": {
        "type": "string",
        "description": "Name of the starting workflow state",
        "minLength": 1
      },
      "end": {
        "oneOf": [{
          "type": "boolean",
          "description": "State end definition",
          "default": true
        }, {
          "type": "object",
          "description": "State end definition",
          "properties": {
            "terminate": {
              "type": "boolean",
              "default": false,
              "description": "If true, completes all execution flows in the given workflow instance"
            },
            "produceEvents": {
              "type": "array",
              "description": "Defines events that should be produced",
              "items": {
                "type": "object",
                "$ref": "#/definitions/produceeventdef"
              },
              "additionalItems": false
            }
          },
          "additionalProperties": false,
          "required": []
        }]
      },
      "produceeventdef": {
        "type": "object",
        "description": "Produce an event and set its data",
        "properties": {
          "eventRef": {
            "type": "string",
            "description": "References a name of a defined event"
          },
          "data": {
            "type": ["string", "object"],
            "description": "If String, expression which selects parts of the states data output to become the data of the produced event. If object a custom object to become the data of produced event."
          },
          "contextAttributes": {
            "type": "object",
            "description": "Add additional event extension context attributes",
            "additionalProperties": {
              "type": "string"
            }
          }
        },
        "additionalProperties": false,
        "required": ["eventRef"]
      },
      "statedatafilter": {
        "type": "object",
        "properties": {
          "input": {
            "type": "string",
            "description": "Workflow expression to filter the state data input"
          },
          "output": {
            "type": "string",
            "description": "Workflow expression that filters the state data output"
          }
        },
        "additionalProperties": false,
        "required": []
      },
      "eventdatafilter": {
        "type": "object",
        "properties": {
          "useData": {
            "type": "boolean",
            "description": "If set to false, event payload is not added/merged to state data. In this case 'data' and 'toStateData' should be ignored. Default is true.",
            "default": true
          },
          "data": {
            "type": "string",
            "description": "Workflow expression that filters the received event payload (default: '${ . }')"
          },
          "toStateData": {
            "type": "string",
            "description": " Workflow expression that selects a state data element to which the filtered event should be added/merged into. If not specified, denotes, the top-level state data element."
          }
        },
        "additionalProperties": false,
        "required": []
      },
      "actiondatafilter": {
        "type": "object",
        "properties": {
          "fromStateData": {
            "type": "string",
            "description": "Workflow expression that selects state data that the state action can use"
          },
          "useResults": {
            "type": "boolean",
            "description": "If set to false, action data results are not added/merged to state data. In this case 'results' and 'toStateData' should be ignored. Default is true.",
            "default": true
          },
          "results": {
            "type": "string",
            "description": "Workflow expression that filters the actions data results"
          },
          "toStateData": {
            "type": "string",
            "description": "Workflow expression that selects a state data element to which the action results should be added/merged into. If not specified, denote, the top-level state data element"
          }
        },
        "additionalProperties": false,
        "required": []
      }
    }
  }
}
