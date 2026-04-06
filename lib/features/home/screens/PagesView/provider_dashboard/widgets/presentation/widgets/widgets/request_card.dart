import 'package:flutter/material.dart';
import 'package:herafy/core/resourses/app_colors.dart';

class RequestCard extends StatelessWidget {
  const RequestCard({super.key, required this.request});
  final Map<String, dynamic> request;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _buildClientAvatar(),
                    const SizedBox(width: 12),
                    Expanded(child: _buildRequestInfo()),
                    _buildTimeAgo(),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  request["description"],
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(AppColors.secondaryColor).withOpacity(0.8),
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 16),
                _buildCardFooter(),
              ],
            ),
          ),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildClientAvatar() {
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: Color(AppColors.primaryColor).withOpacity(0.2),
        ),
      ),
      child: CircleAvatar(
        radius: 22,
        backgroundColor: Color(AppColors.cardsColor),
        child: Icon(Icons.person_outline, color: Color(AppColors.primaryColor)),
      ),
    );
  }

  Widget _buildRequestInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              request["clientName"],
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            if (request["isUrgent"]) ...[
              const SizedBox(width: 8),
              _buildUrgentBadge(),
            ],
          ],
        ),
        const SizedBox(height: 2),
        Row(
          children: [
            Icon(Icons.location_on, size: 14, color: Colors.grey[400]),
            const SizedBox(width: 4),
            Text(
              request["location"],
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildUrgentBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(6),
      ),
      child: const Text(
        "عاجل",
        style: TextStyle(
          color: Colors.red,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildTimeAgo() {
    return Text(
      request["timeAgo"],
      style: TextStyle(fontSize: 11, color: Colors.grey[400]),
    );
  }

  Widget _buildCardFooter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildTag(Icons.category_outlined, request["service"]),
        Text(
          "${request["budget"]} ج.م",
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w900,
            color: Color(0xFF43C59E),
          ),
        ),
      ],
    );
  }

  Widget _buildTag(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Color(AppColors.cardsColor),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: Color(AppColors.primaryColor)),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Color(AppColors.primaryColor),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextButton(
              onPressed: () {},
              child: Text("تجاهل", style: TextStyle(color: Colors.grey[500])),
            ),
          ),
          Container(width: 1, height: 20, color: Colors.grey[200]),
          Expanded(
            child: TextButton(
              onPressed: () {},
              child: Text(
                "تقديم عرض",
                style: TextStyle(
                  color: Color(AppColors.primaryColor),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
