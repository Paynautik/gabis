import re

with open('lib/features/landing/gabis_landing_v3.dart', 'r') as f:
    text = f.read()

old_header = """              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22),
                child: Row(
                  children: [
                    Image.asset('assets/gabislogo.png',
                        height: 24, fit: BoxFit.contain),
                    const Spacer(),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Welcome back',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: GabisV3.ink.withValues(alpha: .45),
                            )),
                        const SizedBox(height: 2),
                        const Text('Deji Adewusi',
                            style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w800,
                                height: 1.1)),
                      ],
                    ),
                    const SizedBox(width: 9),
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: GabisV3.lilac,
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: GabisV3.ink.withValues(alpha: .08), width: 1),
                        image: const DecorationImage(
                          image: AssetImage('assets/images/avatar_user.jpg'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ],
                ),
              ),"""

new_header = """              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Image.asset('assets/gabislogo.png',
                        height: 24, fit: BoxFit.contain),
                    Row(
                      children: [
                        const Spacer(),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('Welcome back',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: GabisV3.ink.withValues(alpha: .45),
                                )),
                            const SizedBox(height: 2),
                            const Text('Deji Adewusi',
                                style: TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w800,
                                    height: 1.1)),
                          ],
                        ),
                        const SizedBox(width: 9),
                        Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: GabisV3.lilac,
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: GabisV3.ink.withValues(alpha: .08), width: 1),
                            image: const DecorationImage(
                              image: AssetImage('assets/images/avatar_user.jpg'),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),"""

text = text.replace(old_header, new_header)

with open('lib/features/landing/gabis_landing_v3.dart', 'w') as f:
    f.write(text)

