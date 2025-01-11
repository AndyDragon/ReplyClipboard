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
export const macScreenshotWidth = 720;
export const macScreenshotHeight = 340;

export const deploymentWebLocation = "/app/replyclipboard";

export const versionLocation = "replyclipboard/version.json";

export const showMacInfo = true;
export const macDmgLocation = "replyclipboard/macos/Reply%20Clipboard%20";
export const macReleaseNotesLocation = "releaseNotes-mac.json";

export const showWindowsInfo = false;
export const windowsInstallerLocation = "replyclipboard/windows";
export const windowsReleaseNotesLocation = "releaseNotes-windows.json";

export const hasTutorial = false;

export type Platform = "macOS" | "windows";

export const platformString: Record<Platform, string> = {
    macOS: "macOS",
    windows: "Windows"
}

export interface Links {
    readonly location: (version: string, flavorSuffix: string) => string;
    readonly actions: {
        readonly name: string;
        readonly action: string;
        readonly target: string;
        readonly suffix: string;
    }[];
}

export const links: Record<Platform, Links | undefined> = {
    macOS: {
        location: (version, suffix) => `${macDmgLocation}${suffix}v${version}.dmg`,
        actions: [
            {
                name: "default",
                action: "download",
                target: "",
                suffix: "",
            },
            {
                name: "cloud sync w/ iCloud",
                action: "download",
                target: "",
                suffix: "with%20iCloud%20"
            }
        ]
    },
    windows: undefined,
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
