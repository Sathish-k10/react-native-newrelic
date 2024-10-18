/**
 * @format
 */

import { AppRegistry, Platform } from 'react-native';
import App from './App';
import { name as appName } from './app.json';
import NewRelic from 'newrelic-react-native-agent';
import * as appVersion from './package.json';

let appToken;

if (Platform.OS === 'ios') {
    appToken = '<YOUR_IOS_TOKEN>';
} else {
    appToken = 'AA6a44141a2e42bb8378c404848cb073963c962d3a-NRMA';
}

const agentConfiguration = {
    analyticsEventEnabled: true,
    crashReportingEnabled: true,
    interactionTracingEnabled: true,
    networkRequestEnabled: true,
    networkErrorRequestEnabled: true,
    httpResponseBodyCaptureEnabled: true,
    loggingEnabled: true,
    logLevel: NewRelic.LogLevel.ERROR,
    webViewInstrumentation: true,
};

NewRelic.startAgent(appToken, agentConfiguration);
NewRelic.setJSAppVersion(appVersion.version);

AppRegistry.registerComponent(appName, () => App);
