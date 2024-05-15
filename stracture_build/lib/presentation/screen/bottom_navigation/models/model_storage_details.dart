import 'package:field/bloc/storage_details/storage_details_cubit.dart';
import 'package:field/injection_container.dart';
import 'package:field/presentation/managers/font_manager.dart';
import 'package:field/widgets/normaltext.dart';
import 'package:flutter/material.dart';

class StorageDetails extends StatelessWidget {
  final String title;
  final String usedFileSize;
  final String iconData;
  final String detailType;
  final double totalSpace;
  final double usedFileSizeUnformat;

  const StorageDetails({
    required this.title,
    required this.usedFileSize,
    required this.iconData,
    required this.detailType,
    required this.totalSpace,
    required this.usedFileSizeUnformat,
    super.key,
  });
  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Image.asset(
          "$iconData",
          color: Colors.blue,
          fit: BoxFit.fitHeight,
          height: 38,
          width: 38,
        ),
        const SizedBox(
          width: 10,
        ),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: NormalTextWidget(
                      title,
                      fontWeight: AFontWight.medium,
                      textAlign: TextAlign.start,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    usedFileSize == "0.00 MB"
                        ? "0.00 MB"
                        : usedFileSize != "0.00 B"
                            ? usedFileSize
                            : "0.00 MB",
                    style: const TextStyle(fontSize: 14),
                    textScaleFactor: 1,
                  )
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              if (totalSpace > 0)
                LinearProgressIndicator(
                  minHeight: 6,
                  backgroundColor: Color.fromARGB(137, 127, 182, 243),
                  color: Colors.blue,
                  value: (usedFileSizeUnformat.isFinite && totalSpace.isFinite) ? (usedFileSizeUnformat / totalSpace) * 20 : 0,
                ),
              const SizedBox(
                height: 5,
              ),
              InkWell(
                  onTap: () {
                    getIt<StorageDetailsCubit>().onClickToManage(context, fileType: detailType);
                  },
                  child: Text(
                    "Click to manage data.",
                    style: const TextStyle(fontSize: 12),
                  ))
            ],
          ),
        ),
      ],
    );
  }
}
