import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';

class AboutAppContactList extends StatelessWidget {
  const AboutAppContactList({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        ListTile(
          leading: Icon(RemixIcons.map_pin_2_line),
          title: Text('Alamat', style: TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(
            'Jl. Pd. Kopi Raya, RT.1/RW.3, Pd. Kopi, Kec. Duren Sawit, Kota Jakarta Timur, Daerah Khusus Ibukota Jakarta 13460',
          ),
        ),
        ListTile(
          leading: Icon(RemixIcons.phone_line),
          title: Text(
            'WhatsApp / Telepon',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text('+62 853-3338-3432'),
        ),
        ListTile(
          leading: Icon(RemixIcons.mail_line),
          title: Text('Email', style: TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text('superadmin@wifiber.web.id'),
        ),
      ],
    );
  }
}
