import AboutFeature

extension TeamDTO.MemberDTO {
    static func fixture(
        name: String = "Member One",
        role: String? = "Organizer",
        linkedin: String? = nil,
        twitter: String? = nil,
        slack: String? = nil,
        imageURL: String = "/img/team/member-one.jpg"
    ) -> Self {
        TeamDTO.MemberDTO(
            name: name,
            role: role,
            linkedin: linkedin,
            twitter: twitter,
            slack: slack,
            imageURL: imageURL
        )
    }
}
