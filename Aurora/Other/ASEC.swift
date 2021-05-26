//
// Aurora
// File created by Adrian Baumgart on 26.05.21.
//
// Licensed under the MIT License
// Copyright © 2021 Lea Baumgart. All rights reserved.
//
// https://git.abmgrt.dev/exc_bad_access/aurora
//

// Aperture Science Enrichment Center

import Foundation
import SwiftyJSON

public enum ASEC {
    public static var credential_name = "Aperture Science Enrichment Center"
    public static var credential_key = "thecakeisalie"

    public static var data = ASECData()
}

public class ASECData {
    var servers: [CloudServer] {
        return [.init(JSON(ASECDataRaw.glados)), .init(JSON(ASECDataRaw.wheatley))]
    }

    var volumes: [CloudVolume] {
        return [
            .init(JSON(ASECDataRaw.moralityCore)),
            .init(JSON(ASECDataRaw.curiosityCore)),
            .init(JSON(ASECDataRaw.intelligenceCore)),
            .init(JSON(ASECDataRaw.angerCore)),
        ]
    }

    var networks: [CloudNetwork] {
        return [
            .init(JSON(ASECDataRaw.internalNetwork)),
        ]
    }

    var floatingIPs: [CloudFloatingIP] {
        return [
            .init(JSON(ASECDataRaw.neurotoxin)),
        ]
    }
}

private enum ASECDataRaw {
    private static var enrichmentCenterLocation: [String: Any] = [
        "id": 69,
        "name": "asec",
        "description": "Aperture Science Enrichment Center",
        "country": "US",
        "city": "Michigan",
        "latitude": 0,
        "longitude": 0,
        "network_zone": "us-east",
    ]

    static var glados: [String: Any] = [
        "id": 0,
        "name": "GLaDOS",
        "status": "running",
        "created": "2007-10-10T12:00:00+00:00",
        "public_net": [
            "ipv4": [
                "ip": "73.186.19.13",
                "blocked": false,
                "dns_ptr": "glados.aperturescience.com",
            ],
            "ipv6": [
                "ip": "fd17:8963:2bfd:d602::/64",
                "blocked": false,
                "dns_ptr": [],
            ],
            "floating_ips": [301],
            "firewalls": [],
        ],
        "private_net": [
            [
                "network": 201,
                "ip": "10.0.10.1",
                "alias_ips": [],
                "mac_address": "7d:95:61:38:e4:54",
            ],
        ],
        "server_type": [
            "id": 1,
            "name": "glados",
            "description": "glados",
            "cores": 4,
            "memory": 99_999_999,
            "disk": 99_999_999,
            "deprecated": false,
            "prices": [
                [
                    "location": "asec",
                    "price_hourly": [
                        "net": "250927520.00000",
                        "gross": "250927520.00000",
                    ],
                    "price_monthly": [
                        "net": "250927520.00000",
                        "gross": "250927520.00000",
                    ],
                ],
            ],
            "storage_type": "network",
            "cpu_type": "dedicated",
        ],
        "datacenter": [
            "id": 69,
            "name": "asec",
            "description": "Aperture Science Enrichment Center",
            "location": enrichmentCenterLocation,
            "server_types": [
                "supported": [],
                "available": [],
                "available_for_migration": [],
            ],
        ],
        "rescue_enabled": false,
        "locked": true,
        "outgoing_traffic": 36_098_346_974_765_799,
        "ingoing_traffic": 4_534_906_843_563_299,
        "included_traffic": 956_758_967_485_747_667,
        "protection": [
            "delete": true,
            "rebuild": true,
        ],
        "labels": [],
        "volumes": [101, 102, 103, 104],
        "load_balancers": [],
        "primary_disk_size": 99_999_999,
    ]

    static var wheatley: [String: Any] = [
        "id": 1,
        "name": "Wheatley",
        "status": "running",
        "created": "2011-04-18T12:00:00+00:00",
        "public_net": [
            "ipv4": [
                "ip": "157.234.75.211",
                "blocked": false,
                "dns_ptr": "wheatley.aperturescience.com",
            ],
            "ipv6": [
                "ip": "fdc1:2d7e:89b0:87a1::/64",
                "blocked": false,
                "dns_ptr": [],
            ],
            "floating_ips": [],
            "firewalls": [],
        ],
        "private_net": [
            [
                "network": 201,
                "ip": "10.0.10.2",
                "alias_ips": [],
                "mac_address": "18:de:e2:2d:cb:31",
            ],
        ],
        "server_type": [
            "id": 2,
            "name": "core",
            "description": "core",
            "cores": 1,
            "memory": 4096,
            "disk": 11983,
            "deprecated": false,
            "prices": [
                [
                    "location": "asec",
                    "price_hourly": [
                        "net": "398573.00000",
                        "gross": "398573.00000",
                    ],
                    "price_monthly": [
                        "net": "398573.00000",
                        "gross": "398573.00000",
                    ],
                ],
            ],
            "storage_type": "local",
            "cpu_type": "dedicated",
        ],
        "datacenter": [
            "id": 69,
            "name": "asec",
            "description": "Aperture Science Enrichment Center",
            "location": enrichmentCenterLocation,
            "server_types": [
                "supported": [],
                "available": [],
                "available_for_migration": [],
            ],
        ],
        "rescue_enabled": false,
        "locked": true,
        "outgoing_traffic": 36_098_346_974_765_799,
        "ingoing_traffic": 4_534_906_843_563_299,
        "included_traffic": 956_758_967_485_747_667,
        "protection": [
            "delete": true,
            "rebuild": true,
        ],
        "labels": [],
        "volumes": [],
        "load_balancers": [],
        "primary_disk_size": 99_999_999,
    ]

    static var moralityCore: [String: Any] = [
        "id": 101,
        "created": "2007-10-10T12:00:00+00:00",
        "name": "Morality Core",
        "server": 0,
        "location": enrichmentCenterLocation,
        "size": 248_639,
        "linux_device": "/dev/core/morality",
        "protection": [
            "delete": false,
        ],
        "labels": [],
        "status": "available",
        "format": "gladoscore",
    ]

    static var curiosityCore: [String: Any] = [
        "id": 102,
        "created": "2007-10-10T12:00:00+00:00",
        "name": "Curiosity Core",
        "server": 0,
        "location": enrichmentCenterLocation,
        "size": 420_942,
        "linux_device": "/dev/core/curiosity",
        "protection": [
            "delete": false,
        ],
        "labels": [],
        "status": "available",
        "format": "gladoscore",
    ]

    static var intelligenceCore: [String: Any] = [
        "id": 103,
        "created": "2007-10-10T12:00:00+00:00",
        "name": "Intelligence Core",
        "server": 0,
        "location": enrichmentCenterLocation,
        "size": 506_395_865,
        "linux_device": "/dev/core/intelligence",
        "protection": [
            "delete": false,
        ],
        "labels": [],
        "status": "available",
        "format": "gladoscore",
    ]

    static var angerCore: [String: Any] = [
        "id": 104,
        "created": "2007-10-10T12:00:00+00:00",
        "name": "Anger Core",
        "server": 0,
        "location": enrichmentCenterLocation,
        "size": 256,
        "linux_device": "/dev/core/anger",
        "protection": [
            "delete": false,
        ],
        "labels": [],
        "status": "available",
        "format": "gladoscore",
    ]

    static var internalNetwork: [String: Any] = [
        "id": 201,
        "name": "Enrichment Center Internal",
        "ip_range": "10.0.10.0/16",
        "subnets": [
            [
                "type": "cloud",
                "ip_range": "10.0.10.0/24",
                "network_zone": "us-east",
                "gateway": "10.0.0.1",
            ],
        ],
        "routes": [],
        "servers": [0, 1],
        "protection": [
            "delete": true,
        ],
        "created": "2007-10-10T12:00:00+00:00",
    ]

    static var neurotoxin: [String: Any] = [
        "id": 301,
        "name": "Neurotoxin",
        "description": "Neurotoxin",
        "ip": "62.128.188.222",
        "type": "ipv4",
        "server": 0,
        "dns_ptr": [
            "ip": "62.128.188.222",
            "dns_ptr": "neurotoxin.internal.aperturescience.com",
        ],
        "home_location": enrichmentCenterLocation,
        "blocked": false,
        "protection": [
            "delete": false,
        ],
        "created": "2007-10-10T12:00:00+00:00",
    ]
}
