/*
 * Copyright (c) 2015, Michael Mitterer (office@mikemitterer.at),
 * IT-Consulting and Development Limited.
 *
 * All Rights Reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

library mdlutils;

import "dart:html" as dom;
import "package:validate/validate.dart";

/**
 * Helper for requesting a proper value
 * from the components HTML-Element
 *
 * Sample:
 *      Dart:
 *          class YourComponent extends MdlTemplateComponent {
 *
 *              bool get savable => DataAttribute.forValue(element.dataset["savable"]).asBool();
 *
 *              ...
 *              }
 *
 *      HTML:
 *          <apikey data-savable="true" data-deletable="true"></apikey>
 */
class DataAttribute {

    /// Converts the given {value} to a {_DataValue} which returns e.g. a boolean
    ///
    /// If value is null and onError-callback is set the return value that comes from
    /// {onError} is used for conversion
    static _DataValue forValue(final dynamic value, { dynamic onError() }) {
        if(value == null && onError != null) {
            return new _DataValue(onError());
        }
        return new _DataValue(value);
    }

    static _DataValue forAttribute(final dom.HtmlElement element,final String name,{ dynamic onError() }) {
        Validate.notNull(element,"Element for attribute $name must not be null");
        Validate.notNull(name,"Attribute-Name for $element must not be null");
        Validate.notBlank(name,"Attribute-Name for $element must not be blank");

        var value;
        if(!element.attributes.containsKey(name)) {
            if(onError != null) {
                value = onError();
            } else {
                throw new ArgumentError("$element has no attribute '$name' set!");
            }
        } else {
            value = element.attributes[name];
        }

        return new _DataValue(value);
    }

    static _DataValue forDataAttribute(final dom.HtmlElement element,final String name,{ dynamic onError() }) {
        Validate.notNull(element,"Element for data attribute $name must not be null");
        Validate.notNull(name,"Data-Attribute for $element must not be null");
        Validate.notBlank(name,"Data-Attribute for $element must not be blank");

        var value;
        if(!element.dataset.containsKey(name)) {
            if(onError != null) {
                value = onError();
            } else {
                throw new ArgumentError("$element has no data-attribute '$name' set!");
            }
        } else {
            value = element.dataset[name];
        }

        return new _DataValue(value);
    }
}

class _DataValue {
    final dynamic _value;

    _DataValue(this._value);

    /// turns value into a boolean
    /// {handleEmptyString} defines how an empty String should be treated
    bool asBool({ final bool handleEmptyStringAs: false }) {
        if(_value == null) {
            return false;

        } else  if(_value is num) {
            return (_value as num).toInt() == 1;

        } else  if(_value is bool) {
            return _value;

        // IntelliJ needs the "as String" to support autocompletion...
        } else if(_value.toString().toLowerCase() == "true" ||
        _value.toString() == "1" || _value.toString() == "yes" ) {

            return true;

        } else if(_value.toString().isEmpty) {
            return handleEmptyStringAs;
        }

        return false;
    }

    String asString() {
        if(_value is String) {
            return _value;
        }
        return _value.toString();
    }

    /// turns value into a boolean
    /// {defaultValue} defines the default value if the attribute is not set
    /// or if attribute can not converted to an int
    int asInt({ final int defaultValue: 0, int onError(final String value) }) {
        if(_value == null) {
            return defaultValue;
        }
        if(_value is num) {
            return (_value as num).toInt();
        }
        final String string = _value.toString();
        if(string.isEmpty) {
            return defaultValue;
        }
        return int.parse(string,onError: (_) {
            if(onError != null) {
                return onError(string);
            }
            return defaultValue;
        });
    }
}

class ElementProperties {
    static const String DISABLED    = "disabled";
    static const String IS_DISABLED = "id-disabled";

    /// Checks if the [element] has either the class set or if the attribute is available
    static bool hasAttributeOrClass(final dom.Element element,final List<String> classesOrAttributes) {
        Validate.notNull(element);
        Validate.notNull(classesOrAttributes);

        for(final String classOrAttribute in classesOrAttributes) {
            final bool hasClass = element.classes.contains(classOrAttribute);
            if(hasClass) {
                return true;
            }
            final bool isAttributeSet = element.attributes.containsKey(classOrAttribute);
            if(isAttributeSet) {
                return ((new _DataValue(element.attributes[classOrAttribute])).asBool(handleEmptyStringAs: true));
            }
        }
        return false;
    }

    /// Checks if [element] has either the attribute "disabled" set or if it has a 'is-disabled' class
    static bool isDisabled(final dom.Element element) => hasAttributeOrClass(element,[ DISABLED, IS_DISABLED]);
}

