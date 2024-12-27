import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:food_ninja/src/bloc/settings/settings_bloc.dart';
import 'package:food_ninja/src/bloc/theme/theme_bloc.dart';
import 'package:food_ninja/src/presentation/utils/app_colors.dart';
import 'package:food_ninja/src/presentation/utils/app_theme.dart';
import 'package:food_ninja/src/presentation/utils/custom_text_style.dart';
import 'package:food_ninja/src/presentation/widgets/buttons/back_button.dart';
import 'package:food_ninja/src/presentation/widgets/loading_indicator.dart';
import 'package:hive_flutter/hive_flutter.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<SettingsBloc, SettingsState>(
      listener: (context, state) async {
        if (state is LogoutInProgress) {
          showDialog(
            context: context,
            builder: (context) => const LoadingIndicator(),
          );
        } else if (state is LogoutSuccess) {
          Navigator.pop(context);
          await Navigator.pushNamedAndRemoveUntil(
            context,
            "/register",
            (route) => false,
          );
        }
      },
      child: Scaffold(
        body: Stack(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: SvgPicture.asset(
                "assets/svg/pattern-small.svg",
              ),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const CustomBackButton(),
                      const SizedBox(height: 20),
                      Text(
                        "Settings",
                        style: CustomTextStyle.size25Weight600Text(),
                      ),
                      const SizedBox(height: 20),

                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          "Dark Mode",
                          style: CustomTextStyle.size16Weight400Text(),
                        ),
                        trailing: Switch(
                          value:
                              Theme.of(context).brightness == Brightness.dark,
                          onChanged: (value) {
                            Hive.box('myBox').put('isDarkMode', value);
                            BlocProvider.of<ThemeBloc>(context).add(
                              ChangeTheme(
                                themeData: Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? AppTheme().lightThemeData
                                    : AppTheme().darkThemeData,
                              ),
                            );
                          },
                        ),
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.pushNamed(context, "/add-food");
                        },
                        child: Container(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Upload Data Makanan",
                                style: CustomTextStyle.size16Weight600Text(),
                              ),
                              Icon(
                                Icons.food_bank_rounded,
                                size: 40,color: Colors.teal,
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.pushNamed(context, "/add-restaurant");
                        },
                        child: Container(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Upload Data Restoran",
                                style: CustomTextStyle.size16Weight600Text(),
                              ),
                              Icon(
                                Icons.home_filled,
                                size: 28,
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.pushNamed(context, "/add-category");
                        },
                        child: Container(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Upload Data Category",
                                style: CustomTextStyle.size16Weight600Text(),
                              ),
                              Icon(
                                Icons.category_rounded,
                                size: 28,
                                color: Colors.orange,
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      // log out
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          "Log Out",
                          style: CustomTextStyle.size16Weight600Text(),
                        ),
                        trailing: const Icon(Icons.logout,color: Colors.red),
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text("Log Out"),
                              content: const Text(
                                "Are you sure you want to log out?",
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: Text(
                                    "Cancel",
                                    style: TextStyle(
                                      color: AppColors().textColor,
                                    ),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    BlocProvider.of<SettingsBloc>(context).add(
                                      Logout(),
                                    );
                                  },
                                  child: const Text(
                                    "Log Out",
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
