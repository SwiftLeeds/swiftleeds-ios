import Foundation

enum ScheduleJSON {
    static let valid = Data(
        """
        {
          "data": {
            "event": {
              "id": "6D7B9E2C-4A1F-4F0B-9A3E-1C2D3E4F5A6B",
              "name": "SwiftLeeds 2026",
              "location": "The Playhouse, Leeds",
              "date": "13-10-2026"
            },
            "events": [
              {
                "id": "6D7B9E2C-4A1F-4F0B-9A3E-1C2D3E4F5A6B",
                "name": "SwiftLeeds 2026",
                "location": "The Playhouse, Leeds",
                "date": "13-10-2026"
              }
            ],
            "days": [
              {
                "date": "2026-10-13T00:00:00Z",
                "name": "Day 1",
                "slots": [
                  {
                    "id": "1A2B3C4D-5E6F-4A1B-8C9D-0E1F2A3B4C5D",
                    "startTime": "09:45",
                    "duration": 30,
                    "date": "2026-10-13T00:00:00Z",
                    "presentation": {
                      "id": "2B3C4D5E-6F7A-4B1C-9D0E-1F2A3B4C5D6E",
                      "title": "Property wrappers",
                      "synopsis": "Everything about DynamicProperty.",
                      "speakers": [
                        {
                          "id": "3C4D5E6F-7A8B-4C1D-0E1F-2A3B4C5D6E7F",
                          "name": "Donny Wals",
                          "biography": "A curious, passionate iOS developer.",
                          "profileImage": "https://example.invalid/donny.png",
                          "organisation": "DonnyWals.com",
                          "twitter": "donnywals"
                        }
                      ],
                      "image": null,
                      "slidoURL": "https://app.sli.do/event/abc",
                      "videoURL": null
                    }
                  },
                  {
                    "id": "4D5E6F7A-8B9C-4D1E-1F2A-3B4C5D6E7F80",
                    "startTime": "08:30",
                    "duration": 60,
                    "date": "2026-10-13T00:00:00Z",
                    "activity": {
                      "id": "5E6F7A8B-9C0D-4E1F-2A3B-4C5D6E7F8091",
                      "title": "Registration",
                      "subtitle": "Come and say hello",
                      "description": "Pick up your badge.",
                      "image": "registration.jpg",
                      "metadataURL": null
                    }
                  }
                ]
              }
            ]
          }
        }
        """.utf8
    )

    static let slotWithNoContent = Data(
        """
        {
          "data": {
            "event": {
              "id": "6D7B9E2C-4A1F-4F0B-9A3E-1C2D3E4F5A6B",
              "name": "SwiftLeeds 2026",
              "location": "The Playhouse, Leeds",
              "date": "13-10-2026"
            },
            "events": [],
            "days": [
              {
                "date": "2026-10-13T00:00:00Z",
                "name": "Day 1",
                "slots": [
                  {
                    "id": "1A2B3C4D-5E6F-4A1B-8C9D-0E1F2A3B4C5D",
                    "startTime": "09:45",
                    "duration": 30
                  }
                ]
              }
            ]
          }
        }
        """.utf8
    )
}
