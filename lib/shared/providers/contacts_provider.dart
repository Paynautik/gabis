import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/app_contact.dart';

final contactsProvider = Provider<List<AppContact>>((ref) {
  return const [
    AppContact(id: '1', name: 'Sarah Jenkins', phone: '+234 801 234 5678', hasElumo: true),
    AppContact(id: '2', name: 'Michael Chen', phone: '+1 415 555 2671', hasElumo: true),
    AppContact(id: '3', name: 'David O.', phone: '+234 902 333 4444', hasElumo: true),
    AppContact(id: '4', name: 'Emma Watson', phone: '+44 7700 900077', hasElumo: false),
    AppContact(id: '5', name: 'James Carter', phone: '+1 212 555 1234', hasElumo: false),
    AppContact(id: '6', name: 'Fatima Ali', phone: '+234 803 111 2222', hasElumo: false),
    AppContact(id: '7', name: 'Raphael Momoh', phone: '+234 802 000 1111', hasElumo: true),
  ];
});
