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

export const macDmgLocation = "replyclipboard/macos/Reply%20Clipboard%20";
export const macReleaseNotesLocation = "releaseNotes-mac.json";

export const windowsInstallerLocation = "replyclipboard/windows";
export const windowsReleaseNotesLocation = "releaseNotes-windows.json";

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
                suffix: "with%20CloudSync%20"
            }
        ]
    },
    windows: undefined,
};
