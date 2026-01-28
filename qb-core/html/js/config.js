export let NOTIFY_CONFIG = null;

// Version cache busting
const CONFIG_VERSION = '1.0.1';

const defaultConfig = {
    NotificationStyling: {
        group: true,
        position: "top-right",
        progress: true,
    },
    VariantDefinitions: {
        success: {
            classes: "success",
            icon: "done",
        },
        info: {
            classes: "info",
            icon: "info",
        },
        primary: {
            classes: "primary",
            icon: "info",
        },
        error: {
            classes: "error",
            icon: "dangerous",
        },
        warning: {
            classes: "warning",
            icon: "warning",
        },
        inform: {
            classes: "inform",
            icon: "info",
        },
        police: {
            classes: "police",
            icon: "local_police",
        },
        ambulance: {
            classes: "ambulance",
            icon: "fas fa-ambulance",
        },
    },
};

export const determineStyleFromVariant = (variant) => {
    console.log('DEBUG: determineStyleFromVariant called with:', variant);
    
    if (!NOTIFY_CONFIG) {
        console.log('DEBUG: NOTIFY_CONFIG is null, using defaultConfig');
        NOTIFY_CONFIG = defaultConfig;
    }
    
    console.log('DEBUG: Available variants:', Object.keys(NOTIFY_CONFIG.VariantDefinitions));
    
    // Case-insensitive search
    const normalizedVariant = variant ? variant.toLowerCase() : '';
    let variantData = NOTIFY_CONFIG.VariantDefinitions[variant];
    
    // Try exact match first
    if (!variantData) {
        // Try case-insensitive match
        for (const [key, value] of Object.entries(NOTIFY_CONFIG.VariantDefinitions)) {
            if (key.toLowerCase() === normalizedVariant) {
                variantData = value;
                console.log('DEBUG: Found case-insensitive match:', key);
                break;
            }
        }
    }
    
    // Fallback to common types
    if (!variantData) {
        const fallbackTypes = ['info', 'primary', 'success', 'inform'];
        for (const fallbackType of fallbackTypes) {
            if (NOTIFY_CONFIG.VariantDefinitions[fallbackType]) {
                variantData = NOTIFY_CONFIG.VariantDefinitions[fallbackType];
                console.warn(`Style of type: ${variant} does not exist in the config, using fallback: ${fallbackType}`);
                break;
            }
        }
    }
    
    if (!variantData) {
        console.error('DEBUG: No variant found and no fallback available!');
        throw new Error(`Style of type: ${variant}, does not exist in the config and no fallback available`);
    }
    
    console.log('DEBUG: Returning variant data:', variantData);
    return variantData;
};

export const fetchNotifyConfig = async () => {
    console.log('DEBUG: fetchNotifyConfig called');
    try {
        const result = await window.fetchNui("getNotifyConfig", {});
        console.log('DEBUG: fetchNui result:', result);
        NOTIFY_CONFIG = result;
        if (!NOTIFY_CONFIG) {
            console.log('DEBUG: Result is null, using defaultConfig');
            NOTIFY_CONFIG = defaultConfig;
        } else {
            console.log('DEBUG: Using fetched config');
        }
    } catch (error) {
        console.error("Failed to fetch notification config, using default", error);
        NOTIFY_CONFIG = defaultConfig;
    }
};

window.addEventListener("load", async () => {
    console.log('DEBUG: window load event fired at', Date.now());
    await fetchNotifyConfig();
});
