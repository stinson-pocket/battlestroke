const teamMembers = [
  {
    name: "Cam S.",
    role: "HOSA Member & Advocate",
    bio: "As a Stroke Awareness advocate from Dunwoody High School, Cam works with the team to educate the community by connecting the campaign with the school, civic groups, and healthcare advocates to improve stroke prevention, recognition, response as well as to expand awareness across the community."
  },
  {
    name: "HOSA Student Leader",
    role: "HOSA Member & Advocate",
    bio: "As a Stroke Awareness advocate from Dunwoody High School, Cam works with the team to educate the community by connecting the campaign with the school, civic groups, and healthcare advocates to improve stroke prevention, recognition, response as well as to expand awareness across the community."
  },
  {
    name: "HOSA Student Leader",
    role: "HOSA Member & Advocate",
    bio: "As a Stroke Awareness advocate from Dunwoody High School, Cam works with the team to educate the community by connecting the campaign with the school, civic groups, and healthcare advocates to improve stroke prevention, recognition, response as well as to expand awareness across the community."
  }
];

const teamGrid = document.querySelector("#team-grid");

if (teamGrid) {
  teamGrid.innerHTML = teamMembers
    .map(
      (member) => `
        <article class="team-card">
          <h3>${member.name}</h3>
          <p class="team-role">${member.role}</p>
          <p>${member.bio}</p>
        </article>
      `
    )
    .join("");
}
