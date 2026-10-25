import type { EmailTemplateFunction } from "@framework/types";
import {
  escapeHtml,
  renderEmail,
  strong,
  truncateSubject,
} from "@framework/lib/email/render";

/** Where invited partners download the Android app. */
export const APP_DOWNLOAD_URL =
  process.env.APP_DOWNLOAD_URL ??
  "https://github.com/wertania/zweier-app/releases/latest";

const NOTE = "Nicht erwartet? Dann ignorieren Sie diese E-Mail einfach.";

/**
 * Invitation to a couple's space. Partners join inside the app, so the mail
 * links to the APK download instead of a web page.
 */
function invitationMail(
  data: Parameters<EmailTemplateFunction>[0],
  hasAccount: boolean
) {
  const space = data.tenant?.name;
  const spaceHtml = strong(escapeHtml(space ?? data.appName));
  const app = escapeHtml(data.appName);
  return {
    subject: truncateSubject(
      space
        ? `💌 Einladung zu „${space}“ – ${data.appName}`
        : `💌 Einladung zu ${data.appName}`
    ),
    html: renderEmail({
      appName: data.appName,
      logoUrl: data.logoUrl,
      de: {
        heading: "Du wurdest eingeladen 💞",
        lines: [
          `Dein Schatz möchte mit dir Ideen, Ausflüge und Reiseträume in ${spaceHtml} sammeln.`,
          ...(hasAccount
            ? [
                `Öffne ${app} und melde dich mit dieser E-Mail-Adresse an – die Einladung wartet dort auf dich. Noch nicht installiert? Hier gibt es die App:`,
              ]
            : [
                `1. ${app} für Android herunterladen und installieren`,
                `2. Mit dieser E-Mail-Adresse anmelden – du bekommst einen Code`,
                `3. Die Einladung in der App annehmen`,
              ]),
        ],
      },
      button: { link: APP_DOWNLOAD_URL, text: `${data.appName} herunterladen` },
      note: NOTE,
      en: `You have been invited to ${escapeHtml(space ?? data.appName)}. Download the Android app (${escapeHtml(APP_DOWNLOAD_URL)}), sign in with this email address and accept the invitation in the app.`,
    }),
  };
}

export const inviteToCouple: EmailTemplateFunction = async (data) =>
  invitationMail(data, false);

export const inviteToCoupleWhenUserExists: EmailTemplateFunction = async (
  data
) => invitationMail(data, true);
