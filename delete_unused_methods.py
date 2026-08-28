filepath = "lib/features/home/home_screen.dart"
with open(filepath, 'r') as f:
    content = f.read()

# Locate _buildVirtualCardSlide and delete it
start_vcs = content.find("  // --- Slide 3: Virtual Platinum Debit Card ---")
if start_vcs != -1:
    end_vcs = content.find("  // --- Standalone Real Virtual Card / Security Banner ---", start_vcs)
    if end_vcs != -1:
        content = content[:start_vcs] + content[end_vcs:]

# Locate _buildSecurityBanner and delete it
start_sb = content.find("  // --- paynautik.com Payroll Banner ---")
if start_sb != -1:
    end_sb = content.find("  Widget _buildRealSecurityBanner() {", start_sb)
    # Wait, _buildRealSecurityBanner was injected before _buildCarouselBanner, let's see.
    # Let's just locate where _buildSecurityBanner is defined and remove it.
    # It starts with: Widget _buildSecurityBanner() {
    start_sb_def = content.find("  Widget _buildSecurityBanner() {", start_sb)
    if start_sb_def != -1:
        # Find next method or comment
        end_sb_def = content.find("  // --- Standalone Real Virtual Card / Security Banner ---", start_sb_def)
        if end_sb_def != -1:
            content = content[:start_sb] + content[end_sb_def:]
        else:
            # Maybe look for something else
            end_sb_def2 = content.find("  Widget _buildRealSecurityBanner() {", start_sb_def)
            if end_sb_def2 != -1:
                content = content[:start_sb] + content[end_sb_def2:]

with open(filepath, 'w') as f:
    f.write(content)

