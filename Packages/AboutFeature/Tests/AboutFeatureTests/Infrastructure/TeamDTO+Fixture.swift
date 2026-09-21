import AboutFeature

extension TeamDTO.MemberDTO {
    static func fixture(
        name: String = "Adam Rush",
        role: String? = "Founder and Host",
        linkedin: String? = nil,
        twitter: String? = nil,
        slack: String? = nil,
        imageURL: String = "/img/team/rush.jpg"
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
