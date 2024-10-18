// error.logging.js
const NEW_RELIC_API_KEY = '';
const NEW_RELIC_LOGS_API_URL = 'https://log-api.newrelic.com/log/v1';
const NEW_RELIC_LICENSE_KEY = '';

export const sendErrorLogToNewRelic = async (error) => {
    const logPayload = {
        timestamp: Date.now(),
        message: `Error occurred: ${error.message}`,
        level: 'error',
        attributes: {
            errorType: 'Error',
            stack: error.stack,
            service: 'Test',
            env: 'development',
        },
    };

    try {
        const response = await fetch(NEW_RELIC_LOGS_API_URL, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'Api-Key': NEW_RELIC_API_KEY,
                'X-License-Key': NEW_RELIC_LICENSE_KEY,
            },
            body: JSON.stringify(logPayload),
        });

        if (!response.ok) {
            console.error('Failed to send log to New Relic:', response.status, response.statusText);
        } else {
            console.log('Log sent successfully');
        }
    } catch (err) {
        console.error('Error sending log to New Relic:', err);
    }
};
