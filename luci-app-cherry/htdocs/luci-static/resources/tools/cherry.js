'use strict';
'require baseclass';
'require uci';
'require fs';
'require rpc';
'require request';

const callRCList = rpc.declare({
    object: 'rc',
    method: 'list',
    params: ['name'],
    expect: { '': {} }
});

const callRCInit = rpc.declare({
    object: 'rc',
    method: 'init',
    params: ['name', 'action'],
    expect: { '': {} }
});

const callCherryVersion = rpc.declare({
    object: 'luci.cherry',
    method: 'version',
    expect: { '': {} }
});

const callCherryProfile = rpc.declare({
    object: 'luci.cherry',
    method: 'profile',
    params: [ 'defaults' ],
    expect: { '': {} }
});

const callCherryUpdateSubscription = rpc.declare({
    object: 'luci.cherry',
    method: 'update_subscription',
    params: ['section_id'],
    expect: { '': {} }
});

const callCherryAPI = rpc.declare({
    object: 'luci.cherry',
    method: 'api',
    params: ['method', 'path', 'query', 'body'],
    expect: { '': {} }
});

const callCherryGetIdentifiers = rpc.declare({
    object: 'luci.cherry',
    method: 'get_identifiers',
    expect: { '': {} }
});

const callCherryDebug = rpc.declare({
    object: 'luci.cherry',
    method: 'debug',
    expect: { '': {} }
});

const homeDir = '/etc/cherry';
const profilesDir = `${homeDir}/profiles`;
const subscriptionsDir = `${homeDir}/subscriptions`;
const mixinFilePath = `${homeDir}/mixin.yaml`;
const runDir = `${homeDir}/run`;
const runProfilePath = `${runDir}/config.yaml`;
const providersDir = `${runDir}/providers`;
const ruleProvidersDir = `${providersDir}/rule`;
const proxyProvidersDir = `${providersDir}/proxy`;
const logDir = `/var/log/cherry`;
const appLogPath = `${logDir}/app.log`;
const coreLogPath = `${logDir}/core.log`;
const debugLogPath = `${logDir}/debug.log`;
const nftDir = `${homeDir}/nftables`;

return baseclass.extend({
    homeDir: homeDir,
    profilesDir: profilesDir,
    subscriptionsDir: subscriptionsDir,
    mixinFilePath: mixinFilePath,
    runDir: runDir,
    runProfilePath: runProfilePath,
    ruleProvidersDir: ruleProvidersDir,
    proxyProvidersDir: proxyProvidersDir,
    appLogPath: appLogPath,
    coreLogPath: coreLogPath,
    debugLogPath: debugLogPath,

    status: async function () {
        return (await callRCList('cherry'))?.cherry?.running;
    },

    reload: function () {
        return callRCInit('cherry', 'reload');
    },

    restart: function () {
        return callRCInit('cherry', 'restart');
    },

    version: function () {
        return callCherryVersion();
    },

    profile: function (defaults) {
        return callCherryProfile(defaults);
    },

    updateSubscription: function (section_id) {
        return callCherryUpdateSubscription(section_id);
    },

    updateDashboard: function () {
        return callCherryAPI('POST', '/upgrade/ui');
    },

    openDashboard: async function () {
        const profile = await callCherryProfile({ 'external-ui-name': null, 'external-controller': null, 'secret': null });
        const uiName = profile['external-ui-name'];
        const apiListen = profile['external-controller'];
        const apiSecret = profile['secret'] ?? '';
        if (!apiListen) {
            return Promise.reject('API has not been configured');
        }
        const apiPort = apiListen.substring(apiListen.lastIndexOf(':') + 1);
        const params = {
            host: window.location.hostname,
            hostname: window.location.hostname,
            port: apiPort,
            secret: apiSecret
        };
        const query = new URLSearchParams(params).toString();
        let url;
        if (uiName) {
            url = `http://${window.location.hostname}:${apiPort}/ui/${uiName}/?${query}`;
        } else {
            url = `http://${window.location.hostname}:${apiPort}/ui/?${query}`;
        }
        setTimeout(function () { window.open(url, '_blank') }, 0);
        return Promise.resolve();
    },

    getIdentifiers: function () {
        return callCherryGetIdentifiers();
    },

    listProfiles: function () {
        return L.resolveDefault(fs.list(this.profilesDir), []);
    },

    listRuleProviders: function () {
        return L.resolveDefault(fs.list(this.ruleProvidersDir), []);
    },

    listProxyProviders: function () {
        return L.resolveDefault(fs.list(this.proxyProvidersDir), []);
    },

    getAppLog: function () {
        return L.resolveDefault(fs.read_direct(this.appLogPath));
    },

    getCoreLog: function () {
        return L.resolveDefault(fs.read_direct(this.coreLogPath));
    },

    clearAppLog: function () {
        return fs.write(this.appLogPath);
    },

    clearCoreLog: function () {
        return fs.write(this.coreLogPath);
    },

    debug: function () {
        return callCherryDebug();
    },
})
