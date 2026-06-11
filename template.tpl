___TERMS_OF_SERVICE___

By creating or modifying this file you agree to Google Tag Manager's Community
Template Gallery Developer Terms of Service available at
https://developers.google.com/tag-manager/gallery-tos (or such other URL as
Google may provide), as modified from time to time.


___INFO___

{
  "type": "MACRO",
  "id": "cvt_temp_public_id",
  "version": 1,
  "securityGroups": [],
  "displayName": "OpenAI - GA4 Ecommerce Mapper",
  "categories": [
    "ADVERTISING",
    "CONVERSIONS",
    "UTILITY"
  ],
  "brand": {
    "id": "brand_digitalanalytix",
    "displayName": "DigitalAnalytix"
  },
  "description": "Converts GA4 ecommerce data layer events into OpenAI Measurement Pixel format. Returns a structured object with eventName and eventData ready for the OpenAI Measurement Pixel tag.",
  "containerContexts": [
    "WEB"
  ]
}


___TEMPLATE_PARAMETERS___

[
  {
    "type": "SELECT",
    "name": "outputField",
    "displayName": "Output Field",
    "macrosInSelect": false,
    "selectItems": [
      {
        "value": "all",
        "displayValue": "Full Object (eventName + eventData)"
      },
      {
        "value": "eventName",
        "displayValue": "Event Name Only"
      },
      {
        "value": "eventData",
        "displayValue": "Event Data Only"
      }
    ],
    "simpleValueType": true,
    "defaultValue": "all",
    "help": "Choose what this variable returns. \u003cb\u003eFull Object\u003c/b\u003e returns \u003ccode\u003e{eventName, eventData}\u003c/code\u003e. Use the other options if you need event name and data in separate variables."
  },
  {
    "type": "TEXT",
    "name": "currencyMultiplier",
    "displayName": "Currency Multiplier",
    "simpleValueType": true,
    "defaultValue": "100",
    "help": "Multiplier to convert GA4 decimal amounts to OpenAI integer format. Use \u003cb\u003e100\u003c/b\u003e for USD/EUR/GBP (e.g. 129.99 → 12999). Use \u003cb\u003e1\u003c/b\u003e for zero-decimal currencies like JPY/KRW.",
    "valueValidators": [
      {
        "type": "NON_EMPTY"
      },
      {
        "type": "POSITIVE_NUMBER"
      }
    ]
  },
  {
    "type": "TEXT",
    "name": "dataLayerEventKey",
    "displayName": "Data Layer Event Key",
    "simpleValueType": true,
    "defaultValue": "event",
    "help": "The data layer key that contains the GA4 event name. Default is \u003ccode\u003eevent\u003c/code\u003e."
  },
  {
    "type": "GROUP",
    "name": "customMappingGroup",
    "displayName": "Custom Event Mappings (Optional)",
    "groupStyle": "ZIPPY_CLOSED",
    "subParams": [
      {
        "type": "SIMPLE_TABLE",
        "name": "customMappings",
        "displayName": "Additional Event Mappings",
        "newRowButtonText": "Add Mapping",
        "simpleTableColumns": [
          {
            "defaultValue": "",
            "displayName": "GA4 Event Name",
            "name": "ga4Event",
            "type": "TEXT"
          },
          {
            "defaultValue": "",
            "displayName": "OpenAI Event Name",
            "name": "openaiEvent",
            "type": "SELECT",
            "selectItems": [
              {
                "value": "page_viewed",
                "displayValue": "page_viewed"
              },
              {
                "value": "contents_viewed",
                "displayValue": "contents_viewed"
              },
              {
                "value": "items_added",
                "displayValue": "items_added"
              },
              {
                "value": "checkout_started",
                "displayValue": "checkout_started"
              },
              {
                "value": "order_created",
                "displayValue": "order_created"
              },
              {
                "value": "lead_created",
                "displayValue": "lead_created"
              },
              {
                "value": "registration_completed",
                "displayValue": "registration_completed"
              },
              {
                "value": "appointment_scheduled",
                "displayValue": "appointment_scheduled"
              },
              {
                "value": "subscription_created",
                "displayValue": "subscription_created"
              },
              {
                "value": "trial_started",
                "displayValue": "trial_started"
              },
              {
                "value": "custom",
                "displayValue": "custom"
              }
            ]
          },
          {
            "defaultValue": "",
            "displayName": "OpenAI Data Type",
            "name": "dataType",
            "type": "SELECT",
            "selectItems": [
              {
                "value": "contents",
                "displayValue": "contents"
              },
              {
                "value": "customer_action",
                "displayValue": "customer_action"
              },
              {
                "value": "plan_enrollment",
                "displayValue": "plan_enrollment"
              },
              {
                "value": "custom",
                "displayValue": "custom"
              }
            ]
          }
        ],
        "help": "Map additional GA4 events to OpenAI events beyond the built-in defaults. Custom mappings override built-in mappings."
      }
    ]
  }
]


___SANDBOXED_JS_FOR_WEB_TEMPLATE___

const copyFromDataLayer = require('copyFromDataLayer');
const makeInteger = require('makeInteger');
const makeNumber = require('makeNumber');
const makeString = require('makeString');
const getType = require('getType');
const Math = require('Math');
const log = require('logToConsole');

const BUILTIN_MAP = {
  'page_view': { eventName: 'page_viewed', dataType: 'contents' },
  'view_item': { eventName: 'contents_viewed', dataType: 'contents' },
  'view_item_list': { eventName: 'contents_viewed', dataType: 'contents' },
  'add_to_cart': { eventName: 'items_added', dataType: 'contents' },
  'begin_checkout': { eventName: 'checkout_started', dataType: 'contents' },
  'purchase': { eventName: 'order_created', dataType: 'contents' },
  'generate_lead': { eventName: 'lead_created', dataType: 'customer_action' },
  'sign_up': { eventName: 'registration_completed', dataType: 'customer_action' }
};

const eventKey = data.dataLayerEventKey || 'event';
const ga4Event = copyFromDataLayer(eventKey);

if (!ga4Event) return undefined;

var mapping = lookupMapping(makeString(ga4Event));
if (!mapping) return undefined;

const multiplier = makeNumber(data.currencyMultiplier) || 100;

const eventName = mapping.eventName;
const eventData = buildEventData(mapping.dataType, multiplier);

if (data.outputField === 'eventName') return eventName;
if (data.outputField === 'eventData') return eventData;

return { eventName: eventName, eventData: eventData };

function lookupMapping(ga4EventName) {
  if (data.customMappings && data.customMappings.length > 0) {
    for (var i = 0; i < data.customMappings.length; i++) {
      var row = data.customMappings[i];
      if (makeString(row.ga4Event) === ga4EventName) {
        return { eventName: row.openaiEvent, dataType: row.dataType };
      }
    }
  }

  if (BUILTIN_MAP[ga4EventName]) {
    return BUILTIN_MAP[ga4EventName];
  }

  return null;
}

function buildEventData(dataType, multiplier) {
  var result = { type: dataType };

  var ecommerce = copyFromDataLayer('ecommerce');

  if (ecommerce) {
    if (ecommerce.value != null) {
      result.amount = toLowestDenomination(ecommerce.value, multiplier);
    }

    if (ecommerce.currency) {
      result.currency = makeString(ecommerce.currency);
    }

    if (ecommerce.items && getType(ecommerce.items) === 'array' && ecommerce.items.length > 0) {
      result.contents = mapItems(ecommerce.items, ecommerce.currency, multiplier);
    }
  }

  return result;
}

function mapItems(ga4Items, eventCurrency, multiplier) {
  var contents = [];

  for (var i = 0; i < ga4Items.length; i++) {
    var item = ga4Items[i];
    var content = {};

    if (item.item_id) content.id = makeString(item.item_id);
    if (item.item_name) content.name = makeString(item.item_name);
    if (item.item_category) content.content_type = makeString(item.item_category);
    if (item.quantity != null) content.quantity = makeInteger(item.quantity);

    if (item.price != null) {
      content.amount = toLowestDenomination(item.price, multiplier);
    }

    if (item.currency) {
      content.currency = makeString(item.currency);
    } else if (eventCurrency) {
      content.currency = makeString(eventCurrency);
    }

    contents.push(content);
  }

  return contents;
}

function toLowestDenomination(value, multiplier) {
  return makeInteger(Math.round(makeNumber(value) * multiplier));
}


___WEB_PERMISSIONS___

[
  {
    "instance": {
      "key": {
        "publicId": "read_data_layer"
      },
      "param": [
        {
          "key": "allowedKeys",
          "value": {
            "type": 1,
            "string": "any"
          }
        }
      ]
    },
    "clientAnnotations": {
      "isEditedByUser": true
    },
    "isRequired": true
  },
  {
    "instance": {
      "key": {
        "publicId": "logging"
      },
      "param": [
        {
          "key": "environments",
          "value": {
            "type": 1,
            "string": "debug"
          }
        }
      ]
    },
    "clientAnnotations": {
      "isEditedByUser": true
    },
    "isRequired": true
  }
]


___TESTS___

scenarios:
- name: Maps GA4 purchase to order_created
  code: |-
    const mockData = {
      outputField: 'all',
      currencyMultiplier: '100',
      dataLayerEventKey: 'event'
    };

    mock('copyFromDataLayer', function(key) {
      if (key === 'event') return 'purchase';
      if (key === 'ecommerce') return {
        value: 129.99,
        currency: 'USD',
        transaction_id: 'T-123',
        items: [
          {
            item_id: 'SKU-001',
            item_name: 'Widget',
            item_category: 'product',
            quantity: 2,
            price: 64.99
          }
        ]
      };
      return undefined;
    });

    const result = runCode(mockData);

    assertThat(result.eventName).isEqualTo('order_created');
    assertThat(result.eventData.type).isEqualTo('contents');
    assertThat(result.eventData.amount).isEqualTo(12999);
    assertThat(result.eventData.currency).isEqualTo('USD');
    assertThat(result.eventData.contents.length).isEqualTo(1);
    assertThat(result.eventData.contents[0].id).isEqualTo('SKU-001');
    assertThat(result.eventData.contents[0].name).isEqualTo('Widget');
    assertThat(result.eventData.contents[0].content_type).isEqualTo('product');
    assertThat(result.eventData.contents[0].quantity).isEqualTo(2);
    assertThat(result.eventData.contents[0].amount).isEqualTo(6499);
- name: Maps GA4 add_to_cart to items_added
  code: |-
    const mockData = {
      outputField: 'all',
      currencyMultiplier: '100',
      dataLayerEventKey: 'event'
    };

    mock('copyFromDataLayer', function(key) {
      if (key === 'event') return 'add_to_cart';
      if (key === 'ecommerce') return {
        value: 25.00,
        currency: 'EUR',
        items: [{ item_id: 'P-100', item_name: 'Gadget', quantity: 1, price: 25.00 }]
      };
      return undefined;
    });

    const result = runCode(mockData);

    assertThat(result.eventName).isEqualTo('items_added');
    assertThat(result.eventData.type).isEqualTo('contents');
    assertThat(result.eventData.amount).isEqualTo(2500);
- name: Maps GA4 generate_lead to lead_created
  code: |-
    const mockData = {
      outputField: 'all',
      currencyMultiplier: '100',
      dataLayerEventKey: 'event'
    };

    mock('copyFromDataLayer', function(key) {
      if (key === 'event') return 'generate_lead';
      if (key === 'ecommerce') return { value: 50.00, currency: 'USD' };
      return undefined;
    });

    const result = runCode(mockData);

    assertThat(result.eventName).isEqualTo('lead_created');
    assertThat(result.eventData.type).isEqualTo('customer_action');
    assertThat(result.eventData.amount).isEqualTo(5000);
- name: Returns undefined for unmapped event
  code: |-
    const mockData = {
      outputField: 'all',
      currencyMultiplier: '100',
      dataLayerEventKey: 'event'
    };

    mock('copyFromDataLayer', function(key) {
      if (key === 'event') return 'scroll';
      return undefined;
    });

    const result = runCode(mockData);

    assertThat(result).isUndefined();
- name: Returns eventName only when configured
  code: |-
    const mockData = {
      outputField: 'eventName',
      currencyMultiplier: '100',
      dataLayerEventKey: 'event'
    };

    mock('copyFromDataLayer', function(key) {
      if (key === 'event') return 'purchase';
      if (key === 'ecommerce') return { value: 10, currency: 'USD', items: [] };
      return undefined;
    });

    const result = runCode(mockData);

    assertThat(result).isEqualTo('order_created');
- name: Custom mapping overrides builtin
  code: |-
    const mockData = {
      outputField: 'all',
      currencyMultiplier: '100',
      dataLayerEventKey: 'event',
      customMappings: [
        { ga4Event: 'purchase', openaiEvent: 'subscription_created', dataType: 'plan_enrollment' }
      ]
    };

    mock('copyFromDataLayer', function(key) {
      if (key === 'event') return 'purchase';
      if (key === 'ecommerce') return { value: 9.99, currency: 'USD' };
      return undefined;
    });

    const result = runCode(mockData);

    assertThat(result.eventName).isEqualTo('subscription_created');
    assertThat(result.eventData.type).isEqualTo('plan_enrollment');
- name: JPY currency multiplier works
  code: |-
    const mockData = {
      outputField: 'all',
      currencyMultiplier: '1',
      dataLayerEventKey: 'event'
    };

    mock('copyFromDataLayer', function(key) {
      if (key === 'event') return 'purchase';
      if (key === 'ecommerce') return {
        value: 1500,
        currency: 'JPY',
        items: [{ item_id: 'J-1', price: 1500, quantity: 1 }]
      };
      return undefined;
    });

    const result = runCode(mockData);

    assertThat(result.eventData.amount).isEqualTo(1500);
    assertThat(result.eventData.contents[0].amount).isEqualTo(1500);


___NOTES___

GA4 Ecommerce to OpenAI Measurement Pixel mapper variable.
Converts standard GA4 ecommerce data layer pushes into OpenAI event format.


