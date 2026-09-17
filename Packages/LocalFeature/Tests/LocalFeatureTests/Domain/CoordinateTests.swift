import LocalFeature
import Testing

@Suite struct CoordinateTests {
    @Test(arguments: [(-90.0, -180.0), (90.0, 180.0), (53.797378, -1.545209)])
    func whenBothValuesAreOnTheGlobe_shouldKeepThem(latitude: Double, longitude: Double) throws {
        let sut = try Coordinate(latitude: latitude, longitude: longitude)

        #expect(sut.latitude == latitude)
        #expect(sut.longitude == longitude)
    }

    @Test(arguments: [-90.000001, 90.000001, .nan, .infinity])
    func whenLatitudeIsOffTheGlobe_shouldThrowLatitudeOutOfRange(latitude: Double) {
        #expect(throws: Coordinate.ParsingError.latitudeOutOfRange) {
            try Coordinate(latitude: latitude, longitude: 0)
        }
    }
}
