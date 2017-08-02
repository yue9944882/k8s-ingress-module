#include <ndk.h> 


typedef struct {
    ngx_flag_t      enable;
} k8s_ingress_main_conf_t; 


static void 
k8s_ingress_init_go_func(ngx_conf_t *cf) {
    void *go_module = dlopen("/usr/local/lib/module.so", RTLD_LAZY);
    if (!go_module) {
        ngx_log_error(NGX_LOG_NOTICE, cf->log, 0, "K8S Ingress Module not found");
        return;
    } else {
        ngx_log_error(NGX_LOG_NOTICE, cf->log, 0, "K8S Ingress Module found");
    }
    u_char* (*fun)(u_char *) = (u_char* (*)(u_char *)) dlsym(go_module, "IngressBootstrap");
    u_char* go = fun((u_char*)"K8S INGRESS PARAM");
    ngx_log_error(NGX_LOG_NOTICE, cf->log, 0, (char*)go);
    return;
};

static char*
k8s_ingress_enable(ngx_conf_t *cf, void *post, void *data) {
    ngx_flag_t *f = data;
    if (*f != 0) {
        ngx_log_error(NGX_LOG_NOTICE, cf->log, 0, "K8S Ingress Dynamic Upstream.."); 
        k8s_ingress_init_go_func(cf);
    }
    return NGX_CONF_OK;
}

static ngx_conf_post_t k8s_ingress_enable_post = {
    k8s_ingress_enable
};


static void* 
k8s_ingress_create_main_conf(ngx_conf_t *cf) {
    k8s_ingress_main_conf_t* conf;
    conf = ngx_palloc(cf->pool, sizeof(k8s_ingress_main_conf_t));
    if (conf == NULL) {
        return NULL;
    }
    conf->enable = NGX_CONF_UNSET;
    return conf;
}

static char*
k8s_ingress_init_main_conf(ngx_conf_t *_conf, void *conf) {
    k8s_ingress_main_conf_t *enableConf = conf;
    // Default switch k8s ingress dynamic upstream
    ngx_conf_init_value(enableConf->enable, 0);
    return NGX_OK;
}



static ngx_command_t k8s_ingress_commands[] = {
    {
        ngx_string("k8s_ingress_upstream"),
        NGX_HTTP_MAIN_CONF | NGX_CONF_FLAG,
        ngx_conf_set_flag_slot,
        0,
        offsetof(k8s_ingress_main_conf_t, enable),
        &k8s_ingress_enable_post
    },
    ngx_null_command
};

static ngx_http_module_t     
k8s_ingress_module_ctx = {
    NULL, NULL, 
    k8s_ingress_create_main_conf, k8s_ingress_init_main_conf, 
    NULL, NULL, 
    NULL, NULL
};

// Module main definition
ngx_module_t k8s_ingress_module = {
    NGX_MODULE_V1,
    &k8s_ingress_module_ctx,
    k8s_ingress_commands,
    NGX_HTTP_MODULE,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NGX_MODULE_V1_PADDING
};