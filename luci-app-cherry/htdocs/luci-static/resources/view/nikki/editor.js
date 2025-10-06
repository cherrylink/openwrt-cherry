'use strict';
'require form';
'require view';
'require uci';
'require fs';
'require tools.cherry as cherry';

return view.extend({
    load: function () {
        return Promise.all([
            uci.load('cherry'),
            cherry.listProfiles(),
            cherry.listRuleProviders(),
            cherry.listProxyProviders(),
        ]);
    },
    render: function (data) {
        const subscriptions = uci.sections('cherry', 'subscription');
        const profiles = data[1];
        const ruleProviders = data[2];
        const proxyProviders = data[3];

        let m, s, o;

        m = new form.Map('cherry');

        s = m.section(form.NamedSection, 'editor', 'editor', _('Editor'));

        o = s.option(form.ListValue, '_file', _('Choose File'));
        o.optional = true;

        for (const profile of profiles) {
            o.value(cherry.profilesDir + '/' + profile.name, _('File:') + profile.name);
        };

        for (const subscription of subscriptions) {
            o.value(cherry.subscriptionsDir + '/' + subscription['.name'] + '.yaml', _('Subscription:') + subscription.name);
        };

        for (const ruleProvider of ruleProviders) {
            o.value(cherry.ruleProvidersDir + '/' + ruleProvider.name, _('Rule Provider:') + ruleProvider.name);
        };

        for (const proxyProvider of proxyProviders) {
            o.value(cherry.proxyProvidersDir + '/' + proxyProvider.name, _('Proxy Provider:') + proxyProvider.name);
        };

        o.value(cherry.mixinFilePath, _('File for Mixin'));
        o.value(cherry.runProfilePath, _('Profile for Startup'));

        o.write = function (section_id, formvalue) {
            return true;
        };
        o.onchange = function (event, section_id, value) {
            return L.resolveDefault(fs.read_direct(value), '').then(function (content) {
                m.lookupOption('_file_content', section_id)[0].getUIElement(section_id).setValue(content);
            });
        };

        o = s.option(form.TextValue, '_file_content',);
        o.rows = 25;
        o.wrap = false;
        o.write = function (section_id, formvalue) {
            const path = m.lookupOption('_file', section_id)[0].formvalue(section_id);
            return fs.write(path, formvalue);
        };
        o.remove = function (section_id) {
            const path = m.lookupOption('_file', section_id)[0].formvalue(section_id);
            return fs.write(path);
        };

        return m.render();
    },
    handleSaveApply: function (ev, mode) {
        return this.handleSave(ev).finally(function () {
            return mode === '0' ? cherry.reload() : cherry.restart();
        });
    },
    handleReset: null
});
