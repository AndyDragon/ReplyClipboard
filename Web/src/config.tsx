export const applicationName = "Reply Clipboard";
export const applicationDescription = "Reply Clipboard is a small utility app for text snippets.";
export const applicationDetails = (
    <>
        This utility lets you store several short snippets of text, often for quick replies on Vero and allows
        quick copy to clipboard without actually making the text visible. I use it for replies, user names for
        accounts and congratulation posts. There is even a facility to have a clipboard placeholder in the
        text so when you click Copy, it places any text clipboard contents in the snippet.
    </>
);
export const showMacScreenshot = true;
export const macScreenshotWidth = 720;
export const macScreenshotHeight = 340;
export const showWindowsScreenshot = false;
export const windowsScreenshotWidth = 1200;
export const windowsScreenshotHeight = 800;

export const deploymentWebLocation = "/app/replyclipboard";

export const versionLocation = "replyclipboard/version.json";

export const enum PlatformLocation {
    DoNotShow,
    AppPortal,
    AppStore,
}

export const showMacInfo: PlatformLocation = PlatformLocation.AppStore;
export const macAppStoreLocation = "https://apps.apple.com/us/app/reply-clipboard/id6477769611";
export const macReleaseNotesLocation = "releaseNotes-mac.json";

export const showIosInfo: PlatformLocation = PlatformLocation.DoNotShow;
export const iosAppStoreLocation = "https://apps.apple.com/us/app/vero-scripts/id6741414908";
export const iosReleaseNotesLocation = "releaseNotes-ios.json";

export const showWindowsInfo: PlatformLocation = PlatformLocation.DoNotShow;
export const windowsAppStoreLocation = "https://apps.microsoft.com/store/detail/9PCZV992L5LG";
export const windowsReleaseNotesLocation = "releaseNotes-windows.json";

export const showAndroidInfo: PlatformLocation = PlatformLocation.DoNotShow;
export const androidInstallerLocation = "https://play.google.com/store/apps/details?id=com.andydragon.vero_scripts";
export const androidReleaseNotesLocation = "releaseNotes-android.json";

export const supportEmail = "andydragon@live.com";

export const hasTutorial = false;

export type Platform = "macOS" | "windows" | "iOS" | "android";

export const platformString: Record<Platform, string> = {
    macOS: "macOS",
    windows: "Windows",
    iOS: "iPhone / iPad",
    android: "Android",
}

export interface Links {
    readonly useAppStore?: true;
    readonly location: (version: string, flavorSuffix: string) => string;
    readonly actions: {
        readonly action: string;
        readonly target: string;
        readonly suffix: string;
    }[];
}

export const links: Record<Platform, Links | undefined> = {
    macOS: {
        useAppStore: true,
        location: (_version, _suffix) => macAppStoreLocation,
        actions: [
            {
                action: "install from Apple app store",
                target: "_blank",
                suffix: "",
            }
        ]
    },
    iOS: {
        useAppStore: true,
        location: (_version, _suffix) => iosAppStoreLocation,
        actions: [
            {
                action: "install from Apple app store",
                target: "_blank",
                suffix: "",
            }
        ]
    },
    windows: {
        useAppStore: true,
        location: (_version, _suffix) => windowsAppStoreLocation,
        actions: [
            {
                action: "install from Microsoft store",
                target: "_blank",
                suffix: "",
            }
        ]
    },
    android: {
        useAppStore: true,
        location: (_version, _suffix) => androidInstallerLocation,
        actions: [
            {
                action: "install from Google Play store",
                target: "_blank",
                suffix: "",
            }
        ]
    },
};

export interface NextStep {
    readonly label: string;
    readonly page: string;
}

export interface Screenshot {
    readonly name: string;
    readonly width?: string;
}

export interface Bullet {
    readonly text: string;
    readonly image?: Screenshot;
    readonly screenshot?: Screenshot;
    readonly link?: string;
}

export interface PageStep {
    readonly screenshot: Screenshot;
    readonly title: string;
    readonly bullets: Bullet[];
    readonly previousStep?: string;
    readonly nextSteps: NextStep[];
}

export const tutorialPages: Record<string, PageStep> = {
};
