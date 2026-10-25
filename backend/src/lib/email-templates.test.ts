import { describe, test, expect } from "bun:test";
import {
  APP_DOWNLOAD_URL,
  inviteToCouple,
  inviteToCoupleWhenUserExists,
} from "./email-templates";

const data = {
  appName: "Zweier",
  baseUrl: "https://zweier-app.resomo.de",
  link: "https://zweier-app.resomo.de/api/v1/user/accept-invitation?token=x",
  tenant: { id: "t1", name: "Anna & <Ben>" },
};

describe("invitation mails", () => {
  test("new partner gets the download link and the steps", async () => {
    const { subject, html } = await inviteToCouple(data);
    expect(subject).toContain("Anna & <Ben>");
    expect(html).toContain(`href="${APP_DOWNLOAD_URL}"`);
    expect(html).toContain("herunterladen");
    expect(html).toContain("Anna &amp; &lt;Ben&gt;"); // escaped in the body
    expect(html).not.toContain("accept-invitation"); // joining happens in the app
  });

  test("existing user also gets the download link", async () => {
    const { html } = await inviteToCoupleWhenUserExists(data);
    expect(html).toContain(`href="${APP_DOWNLOAD_URL}"`);
    expect(html).toContain("wartet dort auf dich");
  });
});
